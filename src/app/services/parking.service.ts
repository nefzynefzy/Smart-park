import { Injectable } from '@angular/core';

@Injectable({ providedIn: 'root' })
export class ParkingService {
  spots = Array.from({ length: 50 }, (_, i) => ({
    id: `A-${i + 1}`,
    status: Math.random() > 0.5 ? 'available' : 'occupied'
  }));

  reservations = Array.from({ length: 10 }, (_, i) => ({
    id: `#RSV-${String(i + 1).padStart(3, '0')}`,
    user: `Utilisateur ${i + 1}`,
    spot: `A-${Math.floor(Math.random() * 50) + 1}`,
    duration: `${Math.floor(Math.random() * 6) + 1}h`,
    amount: Math.floor(Math.random() * 10) + 3
  }));

  getParkingStats() {
    return {
      total: 50,
      occupied: this.spots.filter(s => s.status === 'occupied').length,
      revenue: 1250
    };
  }

  refreshData() {
    // Simulation de mise à jour des données
    this.spots = this.spots.map(spot => ({
      ...spot,
      status: Math.random() > 0.5 ? 'available' : 'occupied'
    }));
  }
}