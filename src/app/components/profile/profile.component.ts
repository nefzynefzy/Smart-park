import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule, Router } from '@angular/router';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { AuthService } from 'src/app/auth/services/auth/auth.service';
import { Subscription } from 'src/app/models/subscription';


@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss']
})
export class ProfileComponent {
  // User data
  user = signal({
    name: '',
    email: '',
    phone: '',
    vehicle: '',
    paymentMethod: '',
    memberSince: '',
    hasSubscription: false
  });

  // Preferences
  preferences = signal({
    emailNotifications: true,
    smsNotifications: true,
    language: 'Français'
  });

  // Reservations
  reservations = signal<any[]>([]);

  // UI states
  isEditing = signal(false);
  activeTab = signal('all');

  constructor(
    private http: HttpClient,
    private authService: AuthService,
    private router: Router
  ) {
    this.loadUserProfile();
  }

  // Helper to get HTTP headers with auth token
  private getHeaders(): HttpHeaders {
    const token = this.authService.getToken();
    return new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    });
  }

  loadUserProfile(): void {
    this.http.get('http://localhost:8082/parking/api/user/profile', { headers: this.getHeaders() }).subscribe({
      next: (data: any) => {
        // Map user data
        const memberSince = data.createdAt ? new Date(data.createdAt).toLocaleDateString('fr-FR') : 'Inconnu';
        const vehicle = data.vehicles && data.vehicles.length > 0 
          ? `${data.vehicles[0].brand} ${data.vehicles[0].model} (${data.vehicles[0].matricule})`
          : 'Aucun véhicule';
        const paymentMethod = data.paymentMethod || 'Non spécifiée';

        this.user.set({
          name: `${data.firstName} ${data.lastName}`,
          email: data.email,
          phone: data.phone,
          vehicle: vehicle,
          paymentMethod: paymentMethod,
          memberSince: memberSince,
          hasSubscription: false // Will be updated by checkActiveSubscription
        });

        // Map preferences
        this.preferences.set({
          emailNotifications: data.emailNotifications ?? true,
          smsNotifications: data.smsNotifications ?? true,
          language: data.language ?? 'Français'
        });

        // Map reservations
        const reservations = data.reservations.map((res: any) => ({
          id: res.parkingSpotId,
          status: this.mapReservationStatus(res),
          parking: `Parking ${res.parkingSpotId}`, // Placeholder
          spot: `Place ${res.parkingSpotId}`, // Placeholder
          date: `${new Date(res.startTime).toLocaleString('fr-FR')} - ${new Date(res.endTime).toLocaleString('fr-FR')}`,
          price: `${res.totalCost.toFixed(2)} €`,
          startTime: res.startTime,
          endTime: res.endTime
        }));
        this.reservations.set(reservations);

        // Check for active subscription
        this.checkActiveSubscription();
      },
      error: (err) => {
        console.error('Error loading profile:', err);
        if (err.status === 401) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
      }
    });
  }

  // Map backend reservation status to frontend status
  private mapReservationStatus(res: { status: string, startTime: string, endTime: string }): string {
    const now = new Date();
    const startTime = new Date(res.startTime);
    const endTime = new Date(res.endTime);
    switch (res.status) {
      case 'CONFIRMED':
        if (endTime < now) return 'completed';
        if (startTime > now) return 'upcoming';
        return 'ongoing';
      case 'PENDING':
        return 'upcoming';
      case 'COMPLETED':
      case 'EXPIRED':
        return 'completed';
      case 'CANCELLED':
        return 'cancelled';
      default:
        return 'completed';
    }
  }

  // Check if the user has an active subscription
  private checkActiveSubscription(): void {
    this.http.get<Subscription[]>('http://localhost:8082/parking/api/user/subscriptions', { headers: this.getHeaders() }).subscribe({
      next: (subscriptions: Subscription[]) => {
        const hasActive = subscriptions.some((sub: Subscription) => sub.status === 'ACTIVE');
        this.user.update((userData) => ({
          ...userData,
          hasSubscription: hasActive
        }));
      },
      error: (err) => {
        console.error('Error checking subscription:', err);
        if (err.status === 401) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
      }
    });
  }

  saveChanges(): void {
    const userData = this.user();
    const [firstName, ...lastNameParts] = userData.name.split(' ');
    const lastName = lastNameParts.join(' ');
    const payload = {
      firstName: firstName,
      lastName: lastName,
      email: userData.email,
      phone: userData.phone
    };

    this.http.put('http://localhost:8082/parking/api/user/profile', payload, { headers: this.getHeaders() }).subscribe({
      next: (data: any) => {
        this.user.set({
          name: `${data.firstName} ${data.lastName}`,
          email: data.email,
          phone: data.phone,
          vehicle: data.vehicles && data.vehicles.length > 0 
            ? `${data.vehicles[0].brand} ${data.vehicles[0].model} (${data.vehicles[0].matricule})`
            : 'Aucun véhicule',
          paymentMethod: data.paymentMethod || 'Non spécifiée',
          memberSince: data.createdAt ? new Date(data.createdAt).toLocaleDateString('fr-FR') : 'Inconnu',
          hasSubscription: false
        });
        this.preferences.set({
          emailNotifications: data.emailNotifications ?? true,
          smsNotifications: data.smsNotifications ?? true,
          language: data.language ?? 'Français'
        });
        this.checkActiveSubscription();
        this.isEditing.set(false);
      },
      error: (err) => {
        console.error('Error updating profile:', err);
        if (err.status === 401) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
      }
    });
  }

  toggleEdit(): void {
    this.isEditing.update((value) => !value);
  }

  toggleNotification(type: 'email' | 'sms'): void {
    this.preferences.update((prefs) => ({
      ...prefs,
      [`${type}Notifications`]: !prefs[`${type}Notifications`]
    }));
    this.savePreferences();
  }

  changeLanguage(lang: string): void {
    this.preferences.update((prefs) => ({
      ...prefs,
      language: lang
    }));
    this.savePreferences();
  }

  private savePreferences(): void {
    const payload = {
      emailNotifications: this.preferences().emailNotifications,
      smsNotifications: this.preferences().smsNotifications,
      language: this.preferences().language
    };
    this.http.put('http://localhost:8082/parking/api/user/preferences', payload, { headers: this.getHeaders() }).subscribe({
      next: () => console.log('Preferences saved successfully'),
      error: (err) => {
        console.error('Error saving preferences:', err);
        if (err.status === 401) {
          this.authService.logout();
          this.router.navigate(['/login']);
        }
      }
    });
  }

  filterReservations(status: string): void {
    this.activeTab.set(status);
  }
}