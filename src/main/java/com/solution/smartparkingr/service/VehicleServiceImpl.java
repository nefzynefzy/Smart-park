package com.solution.smartparkingr.service;

import com.solution.smartparkingr.model.Vehicle;
import com.solution.smartparkingr.repository.VehicleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class VehicleServiceImpl implements VehicleService {

    @Autowired
    private VehicleRepository vehicleRepository;

    @Override
    public List<Vehicle> getAllVehicles() {
        return vehicleRepository.findAll();
    }

    @Override
    public Vehicle createVehicle(Vehicle vehicle) {
        // Check if the vehicle already exists by matricule
        Vehicle existingVehicle = vehicleRepository.findByMatricule(vehicle.getMatricule()).orElse(null);
        if (existingVehicle != null) {
            // If the vehicle exists, update it (if necessary)
            existingVehicle.setUser(vehicle.getUser()); // Assuming update user or other fields
            return vehicleRepository.save(existingVehicle);
        } else {
            // If the vehicle doesn't exist, create a new one
            return vehicleRepository.save(vehicle);
        }
    }

    @Override
    public Vehicle findByMatricule(String matricule) {
        Optional<Vehicle> vehicle = vehicleRepository.findByMatricule(matricule);
        return vehicle.orElse(null); // Returns null if no vehicle is found
    }

    @Override
    public Vehicle save(Vehicle vehicle) {
        return vehicleRepository.save(vehicle);
    }

    @Override
    public void deleteVehicle(Long id) {
        vehicleRepository.deleteById(id);
    }

    @Override
    public Vehicle updateVehicle(Long id, Vehicle vehicleDetails) {
        Optional<Vehicle> vehicleOptional = vehicleRepository.findById(id);
        if (vehicleOptional.isPresent()) {
            Vehicle vehicle = vehicleOptional.get();
            vehicle.setMatricule(vehicleDetails.getMatricule());
            vehicle.setUser(vehicleDetails.getUser()); // Assuming you're updating the user as well
            // Save the updated vehicle
            return vehicleRepository.save(vehicle);
        }
        return null; // Return null if vehicle not found
    }
    @Override
    public Vehicle createIfNotExists(Vehicle vehicle) {
        return vehicleRepository.findByMatricule(vehicle.getMatricule())
                .orElseGet(() -> vehicleRepository.save(vehicle));
    }

}
