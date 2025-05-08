import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { CommonModule, formatDate } from '@angular/common';
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
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Router } from '@angular/router';
import { StorageService } from 'src/app/auth/services/storage/storage.service';
import { SubscriptionService } from 'src/app/services/subscription.service';

export interface ReservationResponse {
  id: number;
  redirect_url: string;
}

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
    MatSelectModule
  ],
  templateUrl: './reservations.component.html',
  styleUrls: ['./reservations.component.css']
})
export class ReservationComponent implements OnInit {
  availablePlaces: any[] = [];
  reservationForm: FormGroup;
  hasActiveSubscription = false;
  currentStep = 1;
  selectedPlace: any = null;
  placeSelected = false;
  vehicleTypes = ['CAR', 'MOTORCYCLE', 'TRUCK'];
  paymentMethods = ['CREDIT_CARD', 'MOBILE_PAYMENT', 'CASH'];
  calculatedMontant = 0;
  isLoading = false;
  paymentInitiated = false;
  paymentUrl: string | null = null;
  reservationSuccess = false;

  constructor(
    private http: HttpClient,
    private router: Router,
    private snackBar: MatSnackBar,
    private fb: FormBuilder,
    private storageService: StorageService,
    private subscriptionService: SubscriptionService
  ) {
    this.reservationForm = this.fb.group({
      date: ['', Validators.required],
      heureDebut: ['', Validators.required],
      heureFin: ['', Validators.required],
      vehicle: ['', Validators.required],
      vehicleType: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern(/^\d{8}$/)]],
      paymentMethod: ['', Validators.required],
      specialRequest: ['']
    });
  }

  ngOnInit(): void {
    if (!this.storageService.isLoggedIn()) {
      this.snackBar.open('Veuillez vous connecter pour continuer.', 'Fermer', { duration: 5000 });
      this.router.navigate(['/auth']);
      return;
    }

    console.log('Checking active subscription...'); // Debug
    this.subscriptionService.getActiveSubscription(this.storageService.getUserId() || 1).subscribe({
      next: (subscription) => {
        this.hasActiveSubscription = subscription.status === 'ACTIVE';
        console.log('Subscription status:', subscription.status); // Debug
      },
      error: (err) => {
        console.error('Subscription error:', err);
        this.hasActiveSubscription = false; // Allow proceeding without subscription
        this.snackBar.open('Aucun abonnement actif détecté. Vous pouvez réserver sans abonnement, mais envisagez d\'en souscrire un pour des avantages.', 'S\'abonner', {
          duration: 7000
        }).onAction().subscribe(() => this.router.navigate(['/app/user/dashboard/abonnements']));
      }
    });

    this.reservationForm.patchValue({
      date: new Date(),
      heureDebut: '10:00',
      heureFin: '12:00',
      vehicle: '123TU1234',
      vehicleType: 'CAR',
      email: 'user@example.com',
      phone: '12345678',
      paymentMethod: 'CREDIT_CARD'
    });

    this.checkPlaceAvailability();
  }

  getAuthHeaders(): HttpHeaders {
    const token = localStorage.getItem('token');
    console.log('Token retrieved:', token ? 'Present' : 'Missing'); // Debug
    return new HttpHeaders({
      'Authorization': token ? `Bearer ${token}` : '',
      'Content-Type': 'application/json'
    });
  }

  checkPlaceAvailability(): void {
    const date = formatDate(this.reservationForm.get('date')?.value || new Date(), 'yyyy-MM-dd', 'en');
    const startTime = this.reservationForm.get('heureDebut')?.value || '10:00';
    const endTime = this.reservationForm.get('heureFin')?.value || '12:00';
    const query = `date=${date}&startTime=${startTime}&endTime=${endTime}`;

    this.http.get<any[]>(`http://localhost:8082/parking/api/parking-spots/available?${query}`, {
      headers: this.getAuthHeaders()
    }).subscribe({
      next: (response) => {
        console.log('Availability response:', response);
        this.availablePlaces = response.map(place => ({
          id: place.id,
          name: place.name,
          type: place.type.toLowerCase(),
          price: place.price,
          available: place.available,
          reserved: !place.available,
          selected: false,
          features: place.type === 'PREMIUM' ? ['Proche entrée', 'Sécurisé'] : []
        }));
      },
      error: (err) => {
        console.error('Availability error:', err);
        const message = err.status === 401 ? 'Session expirée. Veuillez vous reconnecter.' : 'Impossible de vérifier la disponibilité des places.';
        this.snackBar.open(message, 'Fermer', { duration: 5000 });
        if (err.status === 401) {
          this.storageService.logout();
          this.router.navigate(['/auth']);
        }
      }
    });
  }

  selectPlace(place: any): void {
    if (place.reserved) return;
    this.availablePlaces.forEach(p => p.selected = false);
    place.selected = true;
    this.selectedPlace = place;
    this.placeSelected = true;
    this.calculateMontant();
  }

  nextStep(): void {
    console.log('Next step triggered, current step:', this.currentStep); // Debug
    if (this.currentStep === 1 && !this.placeSelected) {
      this.snackBar.open('Veuillez sélectionner une place.', 'Fermer', { duration: 5000 });
      return;
    }
    if (this.currentStep === 2 && this.reservationForm.invalid) {
      this.reservationForm.markAllAsTouched();
      this.snackBar.open('Veuillez compléter tous les champs obligatoires.', 'Fermer', { duration: 5000 });
      this.debugForm(); // Debug invalid form
      return;
    }
    this.currentStep++;
    if (this.currentStep === 2) {
      this.calculateMontant();
    }
  }

  prevStep(): void {
    if (this.currentStep > 1) {
      this.currentStep--;
    }
  }

  reset(): void {
    this.currentStep = 1;
    this.selectedPlace = null;
    this.placeSelected = false;
    this.reservationSuccess = false;
    this.paymentInitiated = false;
    this.paymentUrl = null;
    this.availablePlaces.forEach(p => p.selected = false);
    this.reservationForm.reset({
      date: new Date(),
      heureDebut: '10:00',
      heureFin: '12:00',
      vehicle: '123TU1234',
      vehicleType: 'CAR',
      email: 'user@example.com',
      phone: '12345678',
      paymentMethod: 'CREDIT_CARD',
      specialRequest: ''
    });
  }

  getPlaceTooltip(place: any): string {
    if (place.reserved) return 'Place réservée';
    return `${place.name} (${place.type === 'standard' ? 'Standard' : 'Premium'}, ${place.price} TND/h)`;
  }

  getPlaceTypeLabel(type: string): string {
    return type === 'standard' ? 'Standard' : 'Premium';
  }

  calculateDuration(): string {
    const start = this.reservationForm.get('heureDebut')?.value;
    const end = this.reservationForm.get('heureFin')?.value;
    if (!start || !end) return '0h';
    const [startHour, startMin] = start.split(':').map(Number);
    const [endHour, endMin] = end.split(':').map(Number);
    const duration = (endHour * 60 + endMin - (startHour * 60 + startMin)) / 60;
    return `${duration}h`;
  }

  calculateMontant(): void {
    if (!this.selectedPlace) {
      this.calculatedMontant = 0;
      return;
    }
    const duration = parseFloat(this.calculateDuration());
    this.calculatedMontant = this.selectedPlace.price * duration;
  }

  debugForm(): void {
    console.log('Form Values:', this.reservationForm.value);
    console.log('Form Valid:', this.reservationForm.valid);
    console.log('Form Errors:', this.reservationForm.errors);
    Object.keys(this.reservationForm.controls).forEach(key => {
      const control = this.reservationForm.get(key);
      console.log(`${key} Errors:`, control?.errors);
    });
  }

  initiatePayment(): void {
    this.paymentInitiated = true;
    this.snackBar.open('Préparation du paiement...', 'Fermer', { duration: 3000 });
  }

  submitReservation(): void {
    if (!this.paymentInitiated) return;
    this.isLoading = true;

    const formDate = formatDate(this.reservationForm.get('date')?.value, 'yyyy-MM-dd', 'en');
    const startTime = this.reservationForm.get('heureDebut')?.value;
    const endTime = this.reservationForm.get('heureFin')?.value;

    const reservationData = {
      userId: this.storageService.getUserId() || 1,
      parkingPlaceId: this.selectedPlace.id,
      matricule: this.reservationForm.get('vehicle')?.value,
      startTime: `${formDate}T${startTime}:00`,
      endTime: `${formDate}T${endTime}:00`,
      vehicleType: this.reservationForm.get('vehicleType')?.value,
      email: this.reservationForm.get('email')?.value,
      phone: this.reservationForm.get('phone')?.value,
      paymentMethod: this.reservationForm.get('paymentMethod')?.value,
      specialRequest: this.reservationForm.get('specialRequest')?.value || '',
      amount: this.calculatedMontant
    };

    this.http.post<ReservationResponse>('http://localhost:8082/parking/api/createReservation', reservationData, {
      headers: this.getAuthHeaders()
    }).subscribe({
      next: (response) => {
        this.isLoading = false;
        this.paymentUrl = response.redirect_url;
        this.reservationSuccess = true;
        this.snackBar.open('Réservation confirmée avec succès!', 'Fermer', { duration: 5000 });
        if (this.paymentUrl) {
          window.open(this.paymentUrl, '_blank');
        }
      },
      error: (err) => {
        this.isLoading = false;
        console.error('Reservation error:', err);
        const message = err.status === 401 ? 'Session expirée. Veuillez vous reconnecter.' : 'Erreur lors de la confirmation de la réservation.';
        this.snackBar.open(message, 'Fermer', { duration: 5000 });
        if (err.status === 401) {
          this.storageService.logout();
          this.router.navigate(['/auth']);
        }
      }
    });
  }

  generateRandomId(): string {
    return Math.random().toString(36).substr(2, 9).toUpperCase();
  }

  getToday(): Date {
    return new Date();
  }
}