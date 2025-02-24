import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private apiUrl = 'http://localhost:8082/parking/api/user';

  constructor(private http: HttpClient) {}

  // 🔹 Récupérer les infos du profil
  getUserProfile(userId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/${userId}`);
  }

  // 🔹 Mettre à jour les infos de l'utilisateur
  updateUserProfile(userId: number, userData: any): Observable<any> {
    return this.http.put(`${this.apiUrl}/update/${userId}`, userData);
  }

  // 🔹 Consulter l'historique des réservations
  getUserReservations(userId: number): Observable<any> {
    return this.http.get(`${this.apiUrl}/${userId}/reservations`);
  }
}
