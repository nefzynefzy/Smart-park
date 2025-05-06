package com.solution.smartparkingr.repository;

import com.solution.smartparkingr.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByReservationId(Long reservationId);
    List<Payment> findBySubscriptionId(Long subscriptionId);
    List<Payment> findByPaymentStatus(String paymentStatus);
    Optional<Payment> findByTransactionId(String transactionId);
}