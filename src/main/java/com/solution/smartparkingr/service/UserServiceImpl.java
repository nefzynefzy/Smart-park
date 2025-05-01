package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.User;
import com.solution.smartparkingr.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Override
    public User findById(Long userId) {
        Optional<User> userOptional = userRepository.findById(userId);
        return userOptional.orElse(null);  // Return null if the user is not found
    }

    @Override
    public User findByEmail(String email) {
        Optional<User> userOptional = userRepository.findByEmail(email);
        return userOptional.orElse(null);  // Return null if the user is not found
    }

    @Override
    public User save(User user) {
        return userRepository.save(user);  // Save the user to the repository
    }

    @Override
    public void delete(Long userId) {
        userRepository.deleteById(userId);  // Delete the user by ID
    }

    @Override
    public boolean existsByEmail(String email) {
        return userRepository.existsByEmail(email);  // Check if the email already exists
    }

    @Override
    public boolean existsByPhone(String phone) {
        return userRepository.existsByPhone(phone);  // Check if the phone number already exists
    }
}
