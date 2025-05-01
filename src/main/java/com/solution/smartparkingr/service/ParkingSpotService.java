package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.ParkingSpot;
import com.solution.smartparkingr.model.Reservation;
import com.solution.smartparkingr.model.ReservationStatus;
import com.solution.smartparkingr.model.Vehicle;
import com.solution.smartparkingr.repository.ParkingSpotRepository;
import com.solution.smartparkingr.repository.ReservationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ParkingSpotService {

    private final ParkingSpotRepository parkingSpotRepository;
    private final ReservationRepository reservationRepository;

    public ParkingSpot assignSpotToVehicle(Vehicle vehicle) {
        ParkingSpot spot = parkingSpotRepository.findFirstByIsAvailableTrue()
                .orElseThrow(() -> new RuntimeException("Aucune place disponible"));

        spot.setAvailable(false);
        spot.setVehicle(vehicle);
        return parkingSpotRepository.save(spot);
    }

    public void releaseSpot(Long spotId) {
        ParkingSpot spot = parkingSpotRepository.findById(spotId)
                .orElseThrow(() -> new RuntimeException("Place non trouvée"));

        spot.setAvailable(true);
        spot.setVehicle(null);
        parkingSpotRepository.save(spot);
    }

    public List<ParkingSpot> getAllSpots() {
        return parkingSpotRepository.findAll();
    }

    public List<ParkingSpot> getAvailableSpots() {
        // Release expired reservations before returning available spots
        releaseExpiredReservations();
        return parkingSpotRepository.findAll()
                .stream()
                .filter(ParkingSpot::isAvailable)
                .toList();
    }

    public void releaseExpiredReservations() {
        List<Reservation> expiredReservations = reservationRepository.findByEndTimeBeforeAndStatus(
                LocalDateTime.now(), ReservationStatus.CONFIRMED);

        for (Reservation reservation : expiredReservations) {
            ParkingSpot spot = reservation.getParkingSpot();
            if (spot != null && !spot.isAvailable()) {
                spot.setAvailable(true);
                spot.setVehicle(null);
                parkingSpotRepository.save(spot);
            }
            reservation.setStatus(ReservationStatus.EXPIRED);
            reservationRepository.save(reservation);
        }
    }
}
