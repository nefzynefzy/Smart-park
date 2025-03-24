import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'http://localhost:8082/parking/api/auth'; // 🔹 Ton URL d'API

  constructor(private http: HttpClient) {}

  // ✅ Méthode Login
  login(credentials: { email: string; password: string }): Observable<any> {
    return this.http.post(`${this.apiUrl}/signin`, credentials);
  }

  // ✅ Méthode Register
  register(userData: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/signup`, userData);
  }
}
