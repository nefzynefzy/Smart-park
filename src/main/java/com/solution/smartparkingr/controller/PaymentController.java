package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.model.Payment;
import com.solution.smartparkingr.model.PaymentMethod;
import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.model.ReservationStatus;
import com.solution.smartparkingr.repository.PaymentRepository;
import com.solution.smartparkingr.repository.ReservationRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;

@RestController
@RequestMapping("/api/payment")
@Tag(name = "Payment API", description = "Endpoints for managing parking payments")
public class PaymentController {

    @Autowired
    private ReservationRepository reservationRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @GetMapping("/callback")
    @Operation(summary = "Handle payment callback", description = "Handles status update after payment (SUCCESS or FAILED)")
    public ResponseEntity<?> handlePaymentCallback(
            @RequestParam @Parameter(description = "Transaction session ID") String session,
            @RequestParam @Parameter(description = "Status from gateway: SUCCESS or FAILED") String status
    ) {
        Payment payment = paymentRepository.findByTransactionId(session)
                .orElse(null);

        if (payment == null) {
            return ResponseEntity.badRequest().body("Paiement introuvable pour la session : " + session);
        }

        Reservation reservation = payment.getReservation();
        if (reservation == null) {
            return ResponseEntity.badRequest().body("Réservation associée introuvable.");
        }

        if ("SUCCESS".equalsIgnoreCase(status)) {
            payment.setPaymentStatus("COMPLETED");
            reservation.setStatus(ReservationStatus.CONFIRMED);
        } else {
            payment.setPaymentStatus("FAILED");
            reservation.setStatus(ReservationStatus.CANCELLED);

            // Libérer la place de parking si elle était associée
            if (reservation.getParkingSpot() != null) {
                reservation.getParkingSpot().setAvailable(true);
                reservation.getParkingSpot().setVehicle(null);
            }
        }

        payment.setPaymentDate(LocalDateTime.now());

        paymentRepository.save(payment);
        reservationRepository.save(reservation);

        return ResponseEntity.ok("Statut de paiement mis à jour : " + status);
    }

}
