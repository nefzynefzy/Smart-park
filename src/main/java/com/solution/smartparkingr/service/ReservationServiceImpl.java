package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.model.ReservationStatus;
import com.solution.smartparkingr.repository.ReservationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
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

    @Override
    public List<Reservation> findByUserId(Long userId) {
        return reservationRepository.findByUserId(userId);
    }

    @Override
    public List<Reservation> findByParkingSpotId(Long parkingSpotId) {
        return reservationRepository.findByParkingSpot_Id(parkingSpotId);
    }

    @Override
    public List<Reservation> findActiveReservations() {
        return reservationRepository.findByStatus(ReservationStatus.CONFIRMED);
    }

    @Override
    public void cancelReservation(Long reservationId) {
        Optional<Reservation> reservation = reservationRepository.findById(reservationId);
        reservation.ifPresent(r -> {
            r.setStatus(ReservationStatus.CANCELLED);
            reservationRepository.save(r);
        });
    }

    @Override
    public boolean isSpotReserved(Long parkingSpotId, LocalDateTime startTime, LocalDateTime endTime) {
        List<Reservation> conflictingReservations = reservationRepository.findByParkingSpotIdAndTimeOverlap(
                parkingSpotId, startTime, endTime);
        return !conflictingReservations.isEmpty();
    }
}