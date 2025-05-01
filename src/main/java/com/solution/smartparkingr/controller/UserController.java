package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.load.response.UserProfileResponse;
import com.solution.smartparkingr.load.response.UserProfileUpdateResponse;
import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.model.User;
import com.solution.smartparkingr.model.Vehicle;
import com.solution.smartparkingr.repository.ReservationRepository;
import com.solution.smartparkingr.repository.UserRepository;
import com.solution.smartparkingr.repository.VehicleRepository;
import com.solution.smartparkingr.security.services.UserDetailsImpl;
import com.solution.smartparkingr.load.response.MessageResponse;
import com.solution.smartparkingr.load.request.ProfileUpdateRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/user")
@CrossOrigin(origins = "*", allowedHeaders = "*")
public class UserController {

    private final UserRepository userRepository;
    @Autowired
    private VehicleRepository vehicleRepository;
    @Autowired
    private ReservationRepository reservationRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

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

        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("Utilisateur introuvable"));

        return ResponseEntity.ok(user); // You might want to return a UserProfileResponse object here
    }

    @PutMapping("/update")
    public ResponseEntity<?> updateProfile(@AuthenticationPrincipal UserDetailsImpl userDetails,
                                           @RequestBody ProfileUpdateRequest updateRequest) {
        // Step 1: Fetch user from DB
        User user = userRepository.findById(userDetails.getId())
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Step 2: Update user information
        user.setFirstName(updateRequest.getFirstName());
        user.setLastName(updateRequest.getLastName());
        user.setEmail(updateRequest.getEmail());
        user.setPhone(updateRequest.getPhone());

        // Step 3: Update password if provided
        if (updateRequest.getPassword() != null && !updateRequest.getPassword().isEmpty()) {
            if (!passwordEncoder.matches(updateRequest.getOldPassword(), user.getPassword())) {
                return ResponseEntity.badRequest().body("Old password is incorrect");
            }
            user.setPassword(passwordEncoder.encode(updateRequest.getPassword()));
        }

        // Step 4: Update vehicle information (matricule)
        if (updateRequest.getMatricule() != null && !updateRequest.getMatricule().isEmpty()) {
            Vehicle vehicle = vehicleRepository.findByUser(user)
                    .orElseThrow(() -> new RuntimeException("Vehicle not found"));
            vehicle.setMatricule(updateRequest.getMatricule());

            // Step 5: Upload image to cloud storage (if provided)
            if (updateRequest.getMatriculeImageUrl() != null && !updateRequest.getMatriculeImageUrl().isEmpty()) {
                String imageUrl = uploadImageToCloud(updateRequest.getMatriculeImageUrl());
                vehicle.setMatriculeImageUrl(imageUrl);  // Save only the URL, not the image itself
            }

            vehicleRepository.save(vehicle);
        }

        // Step 6: Save the updated user profile
        userRepository.save(user);

        // Return updated profile in response
        UserProfileUpdateResponse response = new UserProfileUpdateResponse(
                user.getFirstName(),
                user.getLastName(),
                user.getEmail(),
                user.getPhone(),
                user.isActive(),  // Assuming there is an 'active' field in the User model
                updateRequest.getMatricule(),
                updateRequest.getMatriculeImageUrl()  // You might want to return the updated image URL as well
        );

        return ResponseEntity.ok(response);
    }

    private String uploadImageToCloud(String imageUrl) {
        // Implement image upload to cloud storage (Firebase, S3, etc.)
        // Return the URL of the uploaded image.
        return "https://cloudstorage.com/path/to/image.jpg";  // Example URL
    }
}
