import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class UserService {
  private apiUrl = 'http://localhost:8082/parking/api/user';

  constructor(private http: HttpClient) {}

  // 🔹 Récupérer les infos du profil de l'utilisateur connecté
  getUserProfile(): Observable<any> {
    const token = localStorage.getItem('token');  // Récupérer le token
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });

    return this.http.get(`${this.apiUrl}/profile`, { headers });
  }

  // 🔹 Mettre à jour les infos de l'utilisateur
  updateUserProfile(userData: any): Observable<any> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });

    return this.http.put(`${this.apiUrl}/update`, userData, { headers });
  }

  // 🔹 Consulter l'historique des réservations
  getUserReservations(): Observable<any> {
    const token = localStorage.getItem('token');
    const headers = new HttpHeaders({
      'Authorization': `Bearer ${token}`
    });

    return this.http.get(`${this.apiUrl}/reservations`, { headers });
  }
}
