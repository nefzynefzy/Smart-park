// src/app/services/reservation.service.ts
import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Reservation } from '../../models/reservation.model';

@Injectable({
  providedIn: 'root'
})
export class ReservationService {
  private apiUrl = 'http://localhost:8082/api/reservations'; // Modifie selon ton backend

  constructor(private http: HttpClient) {}

  createReservations(reservations: Reservation[]) {
    return this.http.post(`${this.apiUrl}/multi`, reservations); // Exemple: POST vers /api/reservations/multi
  }
  
}
