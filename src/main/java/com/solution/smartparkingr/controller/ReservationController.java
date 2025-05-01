package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.load.request.ReservationRequest;
import com.solution.smartparkingr.model.*;
import com.solution.smartparkingr.repository.*;
import com.solution.smartparkingr.service.*;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

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
    private VehicleService vehicleService;

    @Autowired
    private UserService userService;

    @Autowired
    private ReservationService reservationService;

    @Autowired
    private ParkingSpotService parkingSpotService;

    @PostMapping("/createReservation")
    public ResponseEntity<?> reserveWithMatricule(@Valid @RequestBody ReservationRequest reservationRequest) {
        System.out.println(">>> JSON reçu : " + reservationRequest);
        String matricule = reservationRequest.getMatricule();
        System.out.println("Matricule reçu : " + matricule);

        // Vérification de l'utilisateur
        User user = userService.findById(reservationRequest.getUserId());
        if (user == null) {
            return ResponseEntity.badRequest().body("Utilisateur non trouvé");
        }

        // Vérification du véhicule, création s'il n'existe pas
        Vehicle vehicle = vehicleService.findByMatricule(matricule);
        if (vehicle == null) {
            vehicle = new Vehicle();
            vehicle.setMatricule(matricule);
            vehicle.setUser(user);
            vehicle = vehicleService.save(vehicle);
        }

        // Vérification de la place de parking
        ParkingSpot parkingSpot = parkingSpotRepository.findById(reservationRequest.getParkingPlaceId()).orElse(null);
        if (parkingSpot == null) {
            return ResponseEntity.badRequest().body("Place de parking non trouvée");
        }

        if (!parkingSpot.isAvailable()) {
            return ResponseEntity.badRequest().body("La place de parking est déjà occupée");
        }

        // Réservation et mise à jour de la place de parking
        parkingSpot.setAvailable(false);
        parkingSpot.setVehicle(vehicle);
        parkingSpotRepository.save(parkingSpot);

        // 🧮 Calculer un montant fictif basé sur la durée
        long minutes = java.time.Duration.between(reservationRequest.getStartTime(), reservationRequest.getEndTime()).toMinutes();
        double amount = minutes * 0.1; // Exemple : 0.1 dinar par minute

        // Création de la réservation sans montant ni méthode de paiement
        Reservation reservation = new Reservation();
        reservation.setUser(user);
        reservation.setVehicle(vehicle);
        reservation.setParkingSpot(parkingSpot);
        reservation.setStartTime(reservationRequest.getStartTime());
        reservation.setEndTime(reservationRequest.getEndTime());
        reservation.setStatus(ReservationStatus.PENDING); // Initial status
        reservation = reservationService.save(reservation);

        // 🧾 Créer un paiement en attente
        String sessionId = "SMT" + System.currentTimeMillis();
        Payment payment = new Payment(
                reservation,
                amount,
                PaymentMethod.CARTE_BANCAIRE, // You can switch this to CARTE_POSTALE if needed
                "PENDING",
                sessionId,
                LocalDateTime.now()
        );
        paymentRepository.save(payment);



        paymentRepository.save(payment);

        // URL de redirection pour le paiement
        String redirectUrl = "https://mock-payment.smt.tn/pay?session=" + sessionId +
                "&return_url=http://localhost:8080/api/payment/callback";

        Map<String, Object> response = new HashMap<>();
        response.put("message", "Réservation créée avec succès. Redirection vers le paiement...");
        response.put("redirect_url", redirectUrl);

        return ResponseEntity.ok(response);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<?> handleValidationErrors(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getFieldErrors().forEach(error -> {
            errors.put(error.getField(), error.getDefaultMessage());
        });
        return ResponseEntity.badRequest().body(errors);
    }
}
