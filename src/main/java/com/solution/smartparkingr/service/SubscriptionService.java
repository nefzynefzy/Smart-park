package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.Subscription;
import com.solution.smartparkingr.model.SubscriptionPlan;
import com.solution.smartparkingr.model.User;
import com.solution.smartparkingr.repository.SubscriptionPlanRepository;
import com.solution.smartparkingr.repository.SubscriptionRepository;
import com.solution.smartparkingr.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;

@Service
public class SubscriptionService {

    @Autowired
    private SubscriptionRepository subscriptionRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private SubscriptionPlanRepository subscriptionPlanRepository;

    public Subscription subscribe(Long userId, String type) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        SubscriptionPlan plan = subscriptionPlanRepository.findByType(type.toUpperCase())
                .orElseThrow(() -> new RuntimeException("Subscription plan not found"));

        Subscription subscription = new Subscription();
        subscription.setUser(user);
        subscription.setType(plan.getType());
        subscription.setAmount(plan.getAmount());
        subscription.setStartDate(LocalDate.now());

        String sessionId = "SMT" + System.currentTimeMillis() + "-" + UUID.randomUUID();
        subscription.setSessionId(sessionId);

        LocalDate endDate;
        switch (plan.getType()) {
            case "MONTHLY":
                endDate = LocalDate.now().plusMonths(1);
                break;
            case "QUARTERLY":
                endDate = LocalDate.now().plusMonths(3);
                break;
            case "YEARLY":
                endDate = LocalDate.now().plusYears(1);
                break;
            default:
                throw new IllegalArgumentException("Invalid subscription type: " + plan.getType());
        }

        subscription.setEndDate(endDate);
        subscription.setActive(false);
        subscription.setAutoRenewal(false);
        subscription.setPaymentStatus("PENDING");

        return subscriptionRepository.save(subscription);
    }

    public Optional<Subscription> getActiveSubscription(Long userId) {
        User user = userRepository.findById(userId).orElseThrow();
        return subscriptionRepository.findByUserAndActiveIsTrue(user);
    }

    public void validatePayment(String sessionId) {
        Subscription subscription = subscriptionRepository.findBySessionId(sessionId)
                .orElseThrow(() -> new RuntimeException("Subscription not found"));

        subscription.setPaymentStatus("COMPLETED");
        subscription.setActive(true);
        subscriptionRepository.save(subscription);
    }
}
