import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ReservationService {
  getUserReservations(userId: number) {
    throw new Error('Method not implemented.');
  }

  private apiUrl = '/api/user/reservation';  // URL de l'API pour créer une réservation

  constructor(private http: HttpClient) { }

  // Fonction pour créer une réservation
  createReservation(reservationData: any): Observable<any> {
    return this.http.post(this.apiUrl, reservationData);
  }
}
