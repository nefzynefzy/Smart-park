import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { User } from '../dashboard-admin/components/user-management/user-management.component';

@Injectable({
  providedIn: 'root'
})
export class AdminService {
  private apiUrl = 'http://localhost:3000/api/admin'; // Remplacez par votre URL d'API

  constructor(private http: HttpClient) {}

  getParkingAnalytics(): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/parking/analytics`);
  }

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>(`${this.apiUrl}/users`);
  }

  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/users/${id}`);
  }

  getParkingSettings(): Observable<any> {
    return this.http.get<any>(`${this.apiUrl}/parking/settings`);
  }

  updateParkingSettings(settings: any): Observable<void> {
    return this.http.put<void>(`${this.apiUrl}/parking/settings`, settings);
  }
}