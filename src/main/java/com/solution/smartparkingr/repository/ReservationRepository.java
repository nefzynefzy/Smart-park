package com.solution.smartparkingr.repository;

import com.solution.smartparkingr.model.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByUserId(Long userId);  // Récupérer les réservations par ID utilisateur
}
