package com.solution.smartparkingr.service;

import com.solution.smartparkingr.load.request.UserProfileUpdateRequest;
import com.solution.smartparkingr.model.ParkingSpot;
import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.model.ReservationStatus;
import com.solution.smartparkingr.model.Subscription;
import com.solution.smartparkingr.model.User;
import com.solution.smartparkingr.model.Vehicle;
import com.solution.smartparkingr.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class UserServiceImpl implements UserService {

    private static final Logger logger = LoggerFactory.getLogger(UserServiceImpl.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private ParkingSpotService parkingSpotService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public User findById(Long userId) {
        logger.debug("Finding user by ID: {}", userId);
        return userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));
    }

    @Override
    public User findByEmail(String email) {
        logger.debug("Finding user by email with all data: {}", email);
        Optional<User> userOptional = userRepository.findByEmailWithAllData(email);
        if (userOptional.isPresent()) {
            logger.debug("User found: {}", email);
            return userOptional.get();
        } else {
            logger.error("User not found with email: {}", email);
            throw new RuntimeException("User not found with email: " + email);
        }
    }

    @Override
    public User getCurrentUserForProfile() {
        logger.debug("Getting current user for profile from SecurityContextHolder");
        if (SecurityContextHolder.getContext().getAuthentication() == null) {
            logger.error("No authentication object found in SecurityContextHolder");
            throw new RuntimeException("No authenticated user found");
        }

        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String email;
        if (principal instanceof UserDetails) {
            email = ((UserDetails) principal).getUsername();
            logger.debug("Principal is UserDetails, extracted email: {}", email);
        } else if (principal instanceof String && !principal.equals("anonymousUser")) {
            email = principal.toString();
            logger.debug("Principal is a String (not anonymousUser), using as email: {}", email);
        } else {
            logger.error("Principal is not a valid user: {}", principal);
            throw new RuntimeException("No valid authenticated user found: " + principal);
        }
        return userRepository.findByEmailForProfile(email)
                .orElseThrow(() -> new RuntimeException("User not found with email: " + email));
    }

    @Override
    public User save(User user) {
        logger.debug("Saving user: {}", user.getEmail());
        return userRepository.save(user);
    }

    @Override
    public void delete(Long userId) {
        logger.debug("Deleting user with ID: {}", userId);
        userRepository.deleteById(userId);
    }

    @Override
    public boolean existsByEmail(String email) {
        logger.debug("Checking if email exists: {}", email);
        return userRepository.existsByEmail(email);
    }

    @Override
    public boolean existsByPhone(String phone) {
        logger.debug("Checking if phone exists: {}", phone);
        return userRepository.existsByPhone(phone);
    }

    @Override
    public User getCurrentUser() {
        logger.debug("Getting current user from SecurityContextHolder");
        if (SecurityContextHolder.getContext().getAuthentication() == null) {
            logger.error("No authentication object found in SecurityContextHolder");
            throw new RuntimeException("No authenticated user found");
        }

        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        String email;
        if (principal instanceof UserDetails) {
            email = ((UserDetails) principal).getUsername();
            logger.debug("Principal is UserDetails, extracted email: {}", email);
        } else if (principal instanceof String && !principal.equals("anonymousUser")) {
            email = principal.toString();
            logger.debug("Principal is a String (not anonymousUser), using as email: {}", email);
        } else {
            logger.error("Principal is not a valid user: {}", principal);
            throw new RuntimeException("No valid authenticated user found: " + principal);
        }
        return findByEmail(email);
    }

    @Override
    public User updateUserProfile(UserProfileUpdateRequest updateRequest) {
        logger.debug("Updating user profile for current user");
        User user = getCurrentUser();

        if (updateRequest.getEmail() != null && !updateRequest.getEmail().equals(user.getEmail())) {
            if (existsByEmail(updateRequest.getEmail())) {
                logger.error("Email already in use: {}", updateRequest.getEmail());
                throw new RuntimeException("Email already in use: " + updateRequest.getEmail());
            }
            user.setEmail(updateRequest.getEmail());
        }

        if (updateRequest.getFirstName() != null) {
            user.setFirstName(updateRequest.getFirstName());
        }
        if (updateRequest.getLastName() != null) {
            user.setLastName(updateRequest.getLastName());
        }
        if (updateRequest.getPhone() != null) {
            user.setPhone(updateRequest.getPhone());
        }

        logger.debug("Saving updated user: {}", user.getEmail());
        return userRepository.save(user);
    }

    @Override
    public void changePassword(String currentPassword, String newPassword) {
        logger.debug("Changing password for current user");
        User user = getCurrentUser();

        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            logger.error("Current password is incorrect for user: {}", user.getEmail());
            throw new RuntimeException("Current password is incorrect");
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        logger.debug("Password updated successfully for user: {}", user.getEmail());
        userRepository.save(user);
    }

    @Override
    public void cancelReservation(Long reservationId) {
        logger.debug("Cancelling reservation with ID: {}", reservationId);
        User user = getCurrentUser();
        Reservation reservation = user.getReservations().stream()
                .filter(r -> r.getId().equals(reservationId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Reservation not found: " + reservationId));
        reservation.setStatus(ReservationStatus.CANCELLED);
        ParkingSpot spot = reservation.getParkingSpot();
        if (spot != null && !spot.isAvailable()) {
            parkingSpotService.releaseSpot(spot.getId());
        }
        userRepository.save(user);
        logger.debug("Reservation cancelled and spot freed: {}", reservationId);
    }

    @Override
    public void updateReservation(Long reservationId, LocalDateTime newStartTime, LocalDateTime newEndTime) {
        logger.debug("Updating reservation with ID: {}", reservationId);
        User user = getCurrentUser();
        Reservation reservation = user.getReservations().stream()
                .filter(r -> r.getId().equals(reservationId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Reservation not found: " + reservationId));
        reservation.setStartTime(newStartTime);
        reservation.setEndTime(newEndTime);
        userRepository.save(user);
        logger.debug("Reservation updated: {}", reservationId);
    }

    @Override
    public void cancelSubscription(Long subscriptionId) {
        logger.debug("Cancelling subscription with ID: {}", subscriptionId);
        User user = getCurrentUser();
        Subscription subscription = user.getSubscriptions().stream()
                .filter(s -> s.getId().equals(subscriptionId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Subscription not found: " + subscriptionId));
        user.getSubscriptions().remove(subscription);
        userRepository.save(user);
        logger.debug("Subscription cancelled: {}", subscriptionId);
    }

    @Override
    public void updateVehicleInfo(Long vehicleId, String matricule, String vehicleType, String brand, String model, String color, String matriculeImageUrl) {
        logger.debug("Updating vehicle with ID: {}", vehicleId);
        User user = getCurrentUser();
        Vehicle vehicle = user.getVehicles().stream()
                .filter(v -> v.getId().equals(vehicleId))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Vehicle not found: " + vehicleId));
        if (matricule != null) vehicle.setMatricule(matricule);
        if (vehicleType != null) vehicle.setVehicleType(vehicleType);
        if (brand != null) vehicle.setBrand(brand);
        if (model != null) vehicle.setModel(model);
        if (color != null) vehicle.setColor(color);
        if (matriculeImageUrl != null) vehicle.setMatriculeImageUrl(matriculeImageUrl);
        userRepository.save(user);
        logger.debug("Vehicle updated: {}", vehicleId);
    }
}