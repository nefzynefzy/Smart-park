package com.solution.smartparkingr.repository;

import com.solution.smartparkingr.model.Subscription;
import com.solution.smartparkingr.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {
    Optional<Subscription> findByUserAndActiveIsTrue(User user);
    Optional<Subscription> findBySessionId(String sessionId);
}
