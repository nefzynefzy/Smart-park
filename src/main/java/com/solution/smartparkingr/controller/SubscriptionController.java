package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.load.request.SubscriptionRequest;
import com.solution.smartparkingr.model.Subscription;
import com.solution.smartparkingr.service.SubscriptionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/subscription")
public class SubscriptionController {

    @Autowired
    private SubscriptionService subscriptionService;

    @PostMapping("/subscribe")
    public ResponseEntity<?> subscribe(@RequestBody SubscriptionRequest subscriptionRequest) {
        Subscription subscription = subscriptionService.subscribe(
                subscriptionRequest.getUserId(),
                subscriptionRequest.getType()
        );
        return ResponseEntity.ok(subscription);
    }


    @GetMapping("/callback")
    public ResponseEntity<?> paymentCallback(@RequestParam String session) {
        subscriptionService.validatePayment(session);
        return ResponseEntity.ok("Subscription payment successfully validated");
    }

    @GetMapping("/active")
    public ResponseEntity<?> getActiveSubscription(@RequestParam Long userId) {
        return ResponseEntity.ok(subscriptionService.getActiveSubscription(userId));
    }

}
