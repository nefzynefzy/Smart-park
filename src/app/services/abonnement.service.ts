import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Abonnement } from '../models/abonnement.model';

@Injectable({
  providedIn: 'root',
})
export class AbonnementService {
  private apiUrl = 'http://localhost:8082/api/abonnements'; // Change selon ton backend

  constructor(private http: HttpClient) {}

  getAll(): Observable<Abonnement[]> {
    return this.http.get<Abonnement[]>(this.apiUrl);
  }

  create(abonnement: Abonnement): Observable<Abonnement> {
    return this.http.post<Abonnement>(this.apiUrl, abonnement);
  }

  delete(id: number): Observable<void> {
    return this.http.delete<void>(`${this.apiUrl}/${id}`);
  }
}
