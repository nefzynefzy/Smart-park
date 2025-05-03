import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common'; // Import direct des directives
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';



@Component({
  selector: 'app-profile',
  standalone: true,
  imports: [
    CommonModule,
     FormsModule, 
     RouterModule
   ],
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.scss']
})
export class ProfileComponent {
  // User data
  user = signal({
    name: 'Sophie Dubois',
    email: 'sophie.dubois@gmail.com',
    phone: '+33 6 12 34 56 78',
    address: '15 Rue de la Paix, 75002 Paris, France',
    license: '123456789ABC',
    vehicle: 'Renault Clio - AB-123-CD',
    paymentMethod: 'Visa se terminant par 4567',
    memberSince: 'Octobre 2023'
  });

  // Preferences
  preferences = signal({
    emailNotifications: true,
    smsNotifications: true,
    language: 'Français'
  });

  // Reservations
  reservations = signal([
    {
      id: 1,
      status: 'ongoing',
      parking: 'Parking Centre-Ville',
      spot: 'Place A-42, Niveau -1',
      date: '14 Avril 2025, 09:30 - 18:00',
      price: '12,50 €'
    },
    {
      id: 2,
      status: 'upcoming',
      parking: 'Parking Gare du Nord',
      spot: 'Place B-15, Niveau 2',
      date: '16 Avril 2025, 14:00 - 17:30',
      price: '8,75 €'
    },
    {
      id: 3,
      status: 'completed',
      parking: 'Parking La Défense',
      spot: 'Place C-28, Niveau 0',
      date: '10 Avril 2025, 08:00 - 17:00',
      price: '15,00 €'
    },
    {
      id: 4,
      status: 'completed',
      parking: 'Parking Opéra',
      spot: 'Place D-05, Niveau -2',
      date: '5 Avril 2025, 19:00 - 23:30',
      price: '9,50 €'
    },
    {
      id: 5,
      status: 'cancelled',
      parking: 'Parking Montparnasse',
      spot: 'Place E-19, Niveau 1',
      date: '2 Avril 2025, 10:00 - 14:00',
      price: '0,00 €'
    }
  ]);

  // UI states
  isEditing = signal(false);
  activeTab = signal('all');

  // Methods
  toggleEdit(): void {
    this.isEditing.update(value => !value);
  }

  saveChanges(): void {
    this.isEditing.set(false);
  }

  toggleNotification(type: 'email' | 'sms'): void {
    this.preferences.update(prefs => ({
      ...prefs,
      [`${type}Notifications`]: !prefs[`${type}Notifications`]
    }));
  }

  changeLanguage(lang: string): void {
    this.preferences.update(prefs => ({
      ...prefs,
      language: lang
    }));
  }

  filterReservations(status: string): void {
    this.activeTab.set(status);
  }
}