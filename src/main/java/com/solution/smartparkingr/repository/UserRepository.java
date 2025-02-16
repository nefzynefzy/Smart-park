package com.solution.smartparkingr.repository;

import com.solution.smartparkingr.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByEmail(String email); // authentication using email
    Boolean existsByEmail(String email); // check if email exists during registration
    Boolean existsByPhone(String phone); // check if phone exists during registration

}
