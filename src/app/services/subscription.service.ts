import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { StorageService } from '../auth/services/storage/storage.service';
import { Subscription } from '../models/interface';

interface Vehicle {
  id: number;
  brand: string;
  model: string;
  matricule: string;
}

interface UserProfile {
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  vehicles: Vehicle[];
}

@Injectable({
  providedIn: 'root'
})
export class SubscriptionService {
  private apiUrl = 'http://localhost:8082/parking/api';

  constructor(
    private http: HttpClient,
    private storageService: StorageService
  ) {}

  private getAuthHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    return new HttpHeaders({
      'Authorization': token ? `Bearer ${token}` : '',
      'Content-Type': 'application/json'
    });
  }

  getActiveSubscription(userId: number): Observable<Subscription> {
    return this.http.get<Subscription>(`${this.apiUrl}/subscriptions/active`, {
      headers: this.getAuthHeaders(),
      params: { userId: userId.toString() }
    }).pipe(
      catchError(err => {
        console.error('Error fetching active subscription:', err);
        return throwError(() => new Error('Failed to fetch active subscription'));
      })
    );
  }

  subscribe(subscriptionType: string, billingCycle: string): Observable<{ redirectUrl: string }> {
    const userId = this.storageService.getUserId() || 1;
    const request = { userId, subscriptionType, billingCycle };
    return this.http.post<{ redirectUrl: string }>(`${this.apiUrl}/subscribe`, request, {
      headers: this.getAuthHeaders()
    }).pipe(
      catchError(err => {
        console.error('Error subscribing:', err);
        return throwError(() => new Error('Failed to subscribe'));
      })
    );
  }

  getUserProfile(): Observable<UserProfile> {
    return this.http.get<UserProfile>(`${this.apiUrl}/user/profile`, {
      headers: this.getAuthHeaders()
    }).pipe(
      catchError(err => {
        console.error('Error fetching user profile:', err);
        return throwError(() => new Error('Failed to fetch user profile'));
      })
    );
  }

  updateUserProfile(profile: UserProfile): Observable<UserProfile> {
    return this.http.put<UserProfile>(`${this.apiUrl}/user/profile`, profile, {
      headers: this.getAuthHeaders()
    }).pipe(
      catchError(err => {
        console.error('Error updating user profile:', err);
        return throwError(() => new Error('Failed to update user profile'));
      })
    );
  }
}