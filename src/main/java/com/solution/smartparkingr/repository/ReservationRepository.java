package com.solution.smartparkingr.repository;

import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.model.ReservationStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByUserId(Long userId);
    List<Reservation> findByParkingSpot_Id(Long parkingSpotId);
    List<Reservation> findByStatus(ReservationStatus status);
    List<Reservation> findByEndTimeBeforeAndStatus(LocalDateTime now, ReservationStatus status);

}
