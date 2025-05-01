package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.Vehicle;
import java.util.List;

public interface VehicleService {

    List<Vehicle> getAllVehicles();

    Vehicle createVehicle(Vehicle vehicle);

    Vehicle findByMatricule(String matricule);

    Vehicle createIfNotExists(Vehicle vehicle);

    Vehicle save(Vehicle vehicle);

    void deleteVehicle(Long id);

    Vehicle updateVehicle(Long id, Vehicle vehicleDetails);
}
