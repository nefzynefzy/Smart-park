package com.solution.smartparkingr.repository;

import com.solution.smartparkingr.model.Subscription;
import com.solution.smartparkingr.model.SubscriptionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface SubscriptionRepository extends JpaRepository<Subscription, Long> {

    @Query("SELECT s FROM Subscription s WHERE s.user.id = :userId AND s.status = :status")
    Optional<Subscription> findByUserIdAndStatus(@Param("userId") Long userId, @Param("status") SubscriptionStatus status);

    Optional<Subscription> findBySessionId(String sessionId);

    List<Subscription> findByEndDateBeforeAndStatus(LocalDate date, SubscriptionStatus status);
    List<Subscription> findBySubscriptionType(String subscriptionType);
}
