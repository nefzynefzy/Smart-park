package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.load.request.ReservationRequest;
import com.solution.smartparkingr.model.*;
import com.solution.smartparkingr.repository.*;
import com.solution.smartparkingr.service.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.Duration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class ReservationController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    @Autowired
    private ReservationRepository reservationRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private ParkingSpotRepository parkingSpotRepository;

    @Autowired
    private SubscriptionRepository subscriptionRepository;

    @Autowired
    private VehicleService vehicleService;

    @Autowired
    private UserService userService;

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private ParkingSpotService parkingSpotService;

    @Autowired
    private SubscriptionService subscriptionService;

    @Value("${server.servlet.context-path:/}")
    private String contextPath;

    @PostMapping("/createReservation")
    public ResponseEntity<?> reserveWithMatricule(@Valid @RequestBody ReservationRequest reservationRequest) {
        System.out.println(">>> JSON reçu : " + reservationRequest);

        // Validate user
        User user = userService.findById(reservationRequest.getUserId());
        if (user == null) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "Bad Request",
                    "message", "Utilisateur non trouvé"
            ));
        }

        // Validate vehicle, create if not exists
        Vehicle vehicle = vehicleService.findByMatricule(reservationRequest.getMatricule());
        if (vehicle == null) {
            vehicle = new Vehicle();
            vehicle.setMatricule(reservationRequest.getMatricule());
            vehicle.setVehicleType(reservationRequest.getVehicleType());
            vehicle.setUser(user);
            vehicle = vehicleService.save(vehicle);
        }

        // Validate parking spot
        ParkingSpot parkingSpot = parkingSpotRepository.findById(reservationRequest.getParkingPlaceId()).orElse(null);
        if (parkingSpot == null) {
            return ResponseEntity.badRequest().body(Map.of(
                    "error", "Bad Request",
                    "message", "Place de parking non trouvée"
            ));
        }

        // Check if spot is available and not reserved during the requested time
        if (!parkingSpot.isAvailable() || reservationService.isSpotReserved(parkingSpot.getId(),
                reservationRequest.getStartTime(), reservationRequest.getEndTime())) {
            return ResponseEntity.status(409).body(Map.of(
                    "error", "Conflict",
                    "message", "La place de parking est déjà réservée pour la période demandée"
            ));
        }

        // Calculate cost and check subscription
        Optional<Subscription> activeSubscription = subscriptionService.getActiveSubscription(user.getId());
        double amount = calculateReservationCost(user, parkingSpot, activeSubscription,
                reservationRequest.getStartTime(), reservationRequest.getEndTime());

        // Update remainingPlaces for subscription-included spots
        List<String> includedPlaces = List.of("A1", "A2");
        if (activeSubscription.isPresent() && includedPlaces.contains(parkingSpot.getName())) {
            Subscription subscription = activeSubscription.get();
            if (subscription.getRemainingPlaces() <= 0) {
                return ResponseEntity.badRequest().body(Map.of(
                        "error", "Bad Request",
                        "message", "Aucune place restante dans l'abonnement"
                ));
            }
            subscription.setRemainingPlaces(subscription.getRemainingPlaces() - 1);
            subscriptionRepository.save(subscription);
        }

        // Update parking spot
        parkingSpot.setAvailable(false);
        parkingSpot.setVehicle(vehicle);
        parkingSpotRepository.save(parkingSpot);

        // Create reservation
        Reservation reservation = new Reservation();
        reservation.setUser(user);
        reservation.setVehicle(vehicle);
        reservation.setParkingSpot(parkingSpot);
        reservation.setStartTime(reservationRequest.getStartTime());
        reservation.setEndTime(reservationRequest.getEndTime());
        reservation.setStatus(ReservationStatus.PENDING);
        reservation.setTotalCost(amount);
        reservation.setCreatedAt(LocalDateTime.now());
        reservation = reservationService.save(reservation);

        // Create payment
        String sessionId = "SMT" + System.currentTimeMillis();
        Payment payment = new Payment(
                reservation,
                amount,
                reservationRequest.getPaymentMethod(),
                "PENDING",
                sessionId,
                LocalDateTime.now()
        );
        paymentRepository.save(payment);

        // Prepare response
        String redirectUrl = "https://mock-payment.smt.tn/pay?session=" + sessionId +
                "&return_url=http://localhost:8082" + contextPath + "/api/payment/callback";

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Réservation créée avec succès. Redirection vers le paiement...");
        response.put("redirect_url", redirectUrl);

        return ResponseEntity.ok(response);
    }

    private double calculateReservationCost(User user, ParkingSpot parkingSpot, Optional<Subscription> activeSubscription,
                                            LocalDateTime startTime, LocalDateTime endTime) {
        double hourlyRate = parkingSpot.getType().equals("standard") ? 5.0 : 8.0;
        long hours = Duration.between(startTime, endTime).toHours();
        if (hours <= 0) hours = 1; // Minimum 1 hour

        double baseCost = hourlyRate * hours;

        // Check subscription
        boolean hasSubscription = activeSubscription.isPresent();
        double discount = 0.0;
        boolean isIncluded = false;

        if (hasSubscription) {
            List<String> includedPlaces = List.of("A1", "A2");
            List<String> discountEligiblePlaces = List.of("A1", "A2", "B1");

            if (includedPlaces.contains(parkingSpot.getName())) {
                isIncluded = true;
            } else if (discountEligiblePlaces.contains(parkingSpot.getName())) {
                discount = 0.2; // 20% discount
            }
        }

        if (isIncluded) {
            return 0.0; // Free for subscription-included spots
        }

        double finalCost = baseCost * (1 - discount);

        // Apply long-duration discount
        if (hours > 5) {
            finalCost *= 0.9; // 10% discount for > 5 hours
        }

        return Math.round(finalCost * 100.0) / 100.0;
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<?> handleValidationErrors(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error -> {
            errors.put(error.getField(), error.getDefaultMessage());
        });
        return ResponseEntity.badRequest().body(Map.of(
                "error", "Bad Request",
                "message", "Validation failed",
                "details", errors
        ));
    }
}