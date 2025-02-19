package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.model.User;
import com.solution.smartparkingr.repository.UserRepository;
import com.solution.smartparkingr.repository.ReservationRepository;
import com.solution.smartparkingr.security.services.UserDetailsImpl;
import com.solution.smartparkingr.load.response.MessageResponse;
import com.solution.smartparkingr.load.response.ReservationResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/user")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class UserController {

    private final UserRepository userRepository;
    private final ReservationRepository reservationRepository;

    public UserController(UserRepository userRepository, ReservationRepository reservationRepository) {
        this.userRepository = userRepository;
        this.reservationRepository = reservationRepository;
    }

    // Modifier les informations du profil utilisateur
    @PutMapping("/update")
    public ResponseEntity<?> updateUserProfile(@AuthenticationPrincipal UserDetailsImpl userDetails,
                                               @Valid @RequestBody User updatedUser) {
        // Récupérer l'utilisateur connecté
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Error: User not found"));

        // Mettre à jour les informations
        user.setFirstName(updatedUser.getFirstName());
        user.setLastName(updatedUser.getLastName());
        user.setPhone(updatedUser.getPhone());
        user.setEmail(updatedUser.getEmail());

        userRepository.save(user);
        return ResponseEntity.ok(new MessageResponse("Profile updated successfully!"));
    }

    // Récupérer l'historique des réservations d'un utilisateur
    @GetMapping("/reservations")
    public ResponseEntity<?> getUserReservations(@AuthenticationPrincipal UserDetailsImpl userDetails) {
        // Récupérer l'historique des réservations de l'utilisateur connecté
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
}
