package com.solution.smartparkingr.controller;

import com.solution.smartparkingr.load.request.SubscriptionRequest;
import com.solution.smartparkingr.model.Subscription;
import com.solution.smartparkingr.service.SubscriptionService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class SubscriptionController {

    @Autowired
    private SubscriptionService subscriptionService;

    @Value("${server.servlet.context-path:/}")
    private String contextPath;

    @PostMapping("/subscribe")
    public ResponseEntity<?> subscribe(@Valid @RequestBody SubscriptionRequest request) {
        String sessionId = subscriptionService.createSubscription(
                request.getUserId(),
                request.getSubscriptionType(),
                request.getBillingCycle()
        );
        String redirectUrl = "https://mock-payment.smt.tn/pay?session=" + sessionId + "&return_url=http://localhost:8082" + contextPath + "/api/subscription/callback";
        return ResponseEntity.ok(Map.of(
                "message", "Abonnement créé avec succès. Redirection vers le paiement...",
                "redirect_url", redirectUrl
        ));
    }

    @PostMapping("/subscription/callback")
    public ResponseEntity<?> handlePaymentCallback(
            @RequestParam String session,
            @RequestParam String status) {
        subscriptionService.updateSubscriptionStatus(session, status);
        return "SUCCESS".equalsIgnoreCase(status)
                ? ResponseEntity.ok("Paiement validé avec succès")
                : ResponseEntity.badRequest().body("Échec du paiement");
    }

    @PostMapping("/subscription/{id}/cancel")
    public ResponseEntity<?> cancelSubscription(@PathVariable Long id) {
        subscriptionService.cancelSubscription(id);
        return ResponseEntity.ok("Abonnement annulé avec succès");
    }

    @PostMapping("/subscription/{id}/renew")
    public ResponseEntity<?> renewSubscription(@PathVariable Long id) {
        subscriptionService.renewSubscription(id);
        return ResponseEntity.ok("Abonnement renouvelé avec succès");
    }
}