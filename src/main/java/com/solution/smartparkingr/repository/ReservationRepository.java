package com.solution.smartparkingr.repository;

import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.model.ReservationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;

public interface ReservationRepository extends JpaRepository<Reservation, Long> {
    List<Reservation> findByUserId(Long userId);
    List<Reservation> findByParkingSpot_Id(Long parkingSpotId);
    List<Reservation> findByStatus(ReservationStatus status);
    List<Reservation> findByEndTimeBeforeAndStatus(LocalDateTime now, ReservationStatus status);

    @Query("SELECT r FROM Reservation r WHERE r.parkingSpot.id = :parkingSpotId " +
            "AND r.startTime < :endTime AND r.endTime > :startTime")
    List<Reservation> findByParkingSpotIdAndTimeOverlap(
            @Param("parkingSpotId") Long parkingSpotId,
            @Param("startTime") LocalDateTime startTime,
            @Param("endTime") LocalDateTime endTime);

    List<Reservation> findByCreatedAtBetween(LocalDateTime start, LocalDateTime end);

    List<Reservation> findByStartTimeBetween(LocalDateTime start, LocalDateTime end);

    List<Reservation> findByStatusNotIn(List<ReservationStatus> statuses);
}