package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.load.response.UserProfileResponse;
import com.solution.smartparkingr.model.User;
import com.solution.smartparkingr.repository.UserRepository;
import com.solution.smartparkingr.security.services.UserDetailsImpl;
import com.solution.smartparkingr.load.response.MessageResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/user")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    /**
     * 🔹 Récupérer les informations de l'utilisateur connecté
     */
    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(@AuthenticationPrincipal UserDetailsImpl userDetails) {
        if (userDetails == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Utilisateur non connecté");
        }

        // Récupérer l'utilisateur depuis la base de données
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        return ResponseEntity.ok(user);
    }

}
