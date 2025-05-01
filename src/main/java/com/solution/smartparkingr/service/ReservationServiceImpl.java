package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.model.ReservationStatus;
import com.solution.smartparkingr.repository.ReservationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class ReservationServiceImpl implements ReservationService {

    private final ReservationRepository reservationRepository;

    @Autowired
    public ReservationServiceImpl(ReservationRepository reservationRepository) {
        this.reservationRepository = reservationRepository;
    }

    @Override
    public Reservation save(Reservation reservation) {
        // Logique pour sauvegarder une réservation
        return reservationRepository.save(reservation);
    }

    @Override
    public Optional<Reservation> findById(Long id) {
        return reservationRepository.findById(id);
    }

    @Override
    public List<Reservation> findAll() {
        return reservationRepository.findAll();
    }

    @Override
    public void deleteById(Long id) {
        reservationRepository.deleteById(id);
    }

    // Méthodes personnalisées
    @Override
    public List<Reservation> findByUserId(Long userId) {
        return reservationRepository.findByUserId(userId);
    }

    @Override
    public List<Reservation> findByParkingPlaceId(Long parkingPlaceId) {
        return List.of();
    }

    @Override
    public List<Reservation> findByParkingSpotId(Long parkingSpotId) {  // Modifier ici
        return reservationRepository.findByParkingSpot_Id(parkingSpotId);  // Modification ici
    }

    @Override
    public List<Reservation> findActiveReservations() {
        return reservationRepository.findByStatus(ReservationStatus.CONFIRMED);
    }

    @Override
    public void cancelReservation(Long reservationId) {
        Optional<Reservation> reservation = reservationRepository.findById(reservationId);
        reservation.ifPresent(r -> {
            r.setStatus(ReservationStatus.CANCELLED);  // Changer le statut de la réservation
            reservationRepository.save(r);
        });
    }
}
