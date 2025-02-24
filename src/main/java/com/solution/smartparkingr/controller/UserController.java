package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.load.response.ReservationResponse;
import com.solution.smartparkingr.model.User;
import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.repository.UserRepository;
import com.solution.smartparkingr.repository.ReservationRepository;
import com.solution.smartparkingr.security.services.UserDetailsImpl;
import com.solution.smartparkingr.load.response.MessageResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/user")  // 👈 Vérifie que c'est bien défini
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class UserController {

    private final ReservationRepository reservationRepository;

    public UserController(ReservationRepository reservationRepository) {
        this.reservationRepository = reservationRepository;
    }

    @GetMapping("/reservations")
    public ResponseEntity<?> getUserReservations(@AuthenticationPrincipal UserDetailsImpl userDetails) {
        List<ReservationResponse> reservations = reservationRepository.findByUserId(userDetails.getId())
                .stream()
                .map(reservation -> new ReservationResponse(
                        reservation.getId(),
                        reservation.getParkingLot(),
                        reservation.getStartTime(),
                        reservation.getEndTime(),
                        reservation.getStatus()
                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(reservations);
    }
    @PostMapping("/reservations")
    public ResponseEntity<?> createReservation(@AuthenticationPrincipal UserDetailsImpl userDetails,
                                               @Valid @RequestBody Reservation reservation) {
        reservation.setId(userDetails.getId());
        reservation.setStartTime(LocalDateTime.now());
        reservation.setStatus("PENDING");  // Statut par défaut

        reservationRepository.save(reservation);
        return ResponseEntity.ok(new MessageResponse("Réservation créée avec succès !"));
    }
    @GetMapping("/reservations/test")
    public ResponseEntity<String> testReservation() {
        return ResponseEntity.ok("Test réussi !");
    }

}
