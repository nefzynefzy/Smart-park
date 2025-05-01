package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.Reservation;

import java.util.List;
import java.util.Optional;

public interface ReservationService {
    Reservation save(Reservation reservation);
    Optional<Reservation> findById(Long id);
    List<Reservation> findAll();
    void deleteById(Long id);

    // Méthodes personnalisées
    List<Reservation> findByUserId(Long userId);
    List<Reservation> findByParkingPlaceId(Long parkingPlaceId);

    List<Reservation> findByParkingSpotId(Long parkingSpotId);

    List<Reservation> findActiveReservations();
    void cancelReservation(Long reservationId);
}
