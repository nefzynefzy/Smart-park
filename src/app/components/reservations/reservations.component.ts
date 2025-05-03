import { Component, inject, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { CommonModule, DatePipe } from '@angular/common';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { MatCardModule } from '@angular/material/card';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatSelectModule } from '@angular/material/select';
import { ReactiveFormsModule } from '@angular/forms';

@Component({
  selector: 'app-reservations',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatFormFieldModule,
    MatInputModule,
    MatButtonModule,
    MatIconModule,
    MatCardModule,
    MatTooltipModule,
    MatDatepickerModule,
    MatNativeDateModule,
    MatSnackBarModule,
    MatProgressSpinnerModule,
    MatSelectModule,
    DatePipe
  ],
  templateUrl: './reservations.component.html',
  styleUrls: ['./reservations.component.css']
})
export class ReservationsComponent implements OnInit {
  reservationForm: FormGroup;
  availablePlaces = [
    { id: 1, name: 'A1', reserved: false, selected: false, type: 'standard', price: 5, features: ['Couvert', 'Proche ascenseur'] },
    { id: 2, name: 'A2', reserved: false, selected: false, type: 'standard', price: 5, features: ['Couvert'] },
    { id: 3, name: 'A3', reserved: true, selected: false, type: 'standard', price: 5, features: [] },
    { id: 4, name: 'B1', reserved: false, selected: false, type: 'premium', price: 8, features: ['Surveillance 24/7', 'Chargeur VE'] },
    { id: 5, name: 'B2', reserved: false, selected: false, type: 'premium', price: 8, features: ['Surveillance 24/7', 'Large'] }
  ];
  
  vehicleTypes = ['Voiture', 'SUV', 'Camionnette', 'Moto'];
  paymentMethods = ['Carte bancaire', 'PayPal', 'Espèces'];
  
  calculatedMontant = 0;
  placeSelected = false;
  currentStep = 1;
  totalSteps = 3;
  selectedPlace: any = null;
  isLoading = false;
  reservationSuccess = false;
  
  // Gestion abonnement
  hasSubscription = false;
  subscriptionDetails: any = null;
  subscriptionDiscount = 0.2;
  allowedSubscriptionPlaces = ['A1', 'A2', 'B1'];
  subscriptionIncludedPlaces = ['A1', 'A2'];

  constructor(private snackBar: MatSnackBar) {
    const fb = inject(FormBuilder);
    this.reservationForm = fb.group({
      date: ['', Validators.required],
      heureDebut: ['', Validators.required],
      heureFin: ['', Validators.required],
      vehicle: ['', Validators.required],
      vehicleType: ['Voiture', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern('[0-9]{8}')]],
      paymentMethod: ['Carte bancaire', Validators.required],
      specialRequest: ['']
    });

    this.reservationForm.valueChanges.subscribe(() => {
      this.calculateMontant();
    });
  }

  ngOnInit() {
    this.checkUserSubscription();
  }

  // Méthodes abonnement
  checkUserSubscription() {
    // Simulation - remplacer par appel API réel
    this.hasSubscription = true;
    if (this.hasSubscription) {
      this.subscriptionDetails = {
        type: 'Premium',
        validUntil: '2024-12-31',
        remainingPlaces: 10,
        monthlyLimit: 20
      };
    }
  }

  isPlaceIncludedInSubscription(place: any): boolean {
    return this.hasSubscription && this.subscriptionIncludedPlaces.includes(place.name);
  }

  isPlaceEligibleForDiscount(place: any): boolean {
    return this.hasSubscription && this.allowedSubscriptionPlaces.includes(place.name);
  }

  getPlaceTooltip(place: any): string {
    if (place.reserved) {
      return 'Cette place est déjà réservée';
    }

    let tooltip = `Place ${place.name} (${this.getPlaceTypeLabel(place.type)})\n`;
    tooltip += `Tarif: ${place.price} TND/h`;

    if (this.isPlaceIncludedInSubscription(place)) {
      tooltip += '\n\n🟢 Incluse dans votre abonnement';
    } else if (this.isPlaceEligibleForDiscount(place)) {
      tooltip += `\n\n🔵 Éligible à ${this.subscriptionDiscount*100}% de réduction`;
    }

    if (place.features.length > 0) {
      tooltip += `\n\nAvantages: ${place.features.join(', ')}`;
    }

    return tooltip;
  }

  // Méthodes de calcul
  calculateMontant(): void {
    if (!this.selectedPlace || !this.reservationForm.get('heureDebut')?.value || !this.reservationForm.get('heureFin')?.value) {
      this.calculatedMontant = 0;
      return;
    }

    if (this.isPlaceIncludedInSubscription(this.selectedPlace)) {
      this.calculatedMontant = 0;
      return;
    }

    const start = new Date(`2000-01-01T${this.reservationForm.get('heureDebut')?.value}`);
    const end = new Date(`2000-01-01T${this.reservationForm.get('heureFin')?.value}`);
    const diffHours = (end.getTime() - start.getTime()) / (1000 * 60 * 60);

    let basePrice = this.selectedPlace.price * diffHours;
    let finalPrice = basePrice;

    if (diffHours > 5) {
      finalPrice *= 0.9;
    }

    if (this.isPlaceEligibleForDiscount(this.selectedPlace)) {
      finalPrice *= (1 - this.subscriptionDiscount);
    }

    this.calculatedMontant = Math.round(finalPrice * 100) / 100;
  }

  getToday(): string {
    return new Date().toISOString().split('T')[0];
  }

  calculateDuration(): string {
    if (!this.reservationForm.get('heureDebut')?.value || !this.reservationForm.get('heureFin')?.value) {
      return '0h';
    }

    const start = new Date(`2000-01-01T${this.reservationForm.get('heureDebut')?.value}`);
    const end = new Date(`2000-01-01T${this.reservationForm.get('heureFin')?.value}`);
    const diffHours = (end.getTime() - start.getTime()) / (1000 * 60 * 60);
    const hours = Math.floor(diffHours);
    const minutes = Math.round((diffHours - hours) * 60);
    
    return `${hours}h${minutes > 0 ? `${minutes}m` : ''}`;
  }

  // Méthodes utilitaires
  generateRandomId(): string {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  getPlaceTypeLabel(type: string): string {
    switch(type) {
      case 'standard': return 'Standard';
      case 'premium': return 'Premium';
      default: return 'Inconnu';
    }
  }

  // Méthodes d'interface
  selectPlace(place: any): void {
    if (place.reserved) {
      this.snackBar.open('Cette place est déjà réservée', 'Fermer', { duration: 3000 });
      return;
    }
    this.availablePlaces.forEach(p => p.selected = false);
    place.selected = true;
    this.placeSelected = true;
    this.selectedPlace = place;
    this.calculateMontant();
  }

  nextStep(): void {
    if (this.currentStep < this.totalSteps) {
      this.currentStep++;
      window.scrollTo(0, 0);
    }
  }

  prevStep(): void {
    if (this.currentStep > 1) {
      this.currentStep--;
      window.scrollTo(0, 0);
    }
  }

  submitReservation(): void {
    if (this.reservationForm.valid && this.placeSelected) {
      this.isLoading = true;
      
      setTimeout(() => {
        const reservationData = {
          ...this.reservationForm.value,
          place: this.selectedPlace,
          total: this.calculatedMontant,
          reservationNumber: 'RES-' + this.generateRandomId(),
          usedSubscription: this.hasSubscription && 
                          (this.isPlaceIncludedInSubscription(this.selectedPlace) || 
                           this.isPlaceEligibleForDiscount(this.selectedPlace))
        };
        
        console.log('Réservation confirmée :', reservationData);
        this.isLoading = false;
        this.reservationSuccess = true;
        
        if (this.isPlaceIncludedInSubscription(this.selectedPlace)) {
          this.snackBar.open('Place réservée avec votre abonnement!', 'Fermer', { duration: 5000 });
        } else {
          this.snackBar.open('Réservation confirmée!', 'Fermer', { duration: 5000 });
        }
      }, 1500);
    }
  }

  reset(): void {
    this.reservationForm.reset({
      vehicleType: 'Voiture',
      paymentMethod: 'Carte bancaire'
    });
    this.availablePlaces.forEach(p => p.selected = false);
    this.placeSelected = false;
    this.currentStep = 1;
    this.selectedPlace = null;
    this.calculatedMontant = 0;
    this.reservationSuccess = false;
  }
}