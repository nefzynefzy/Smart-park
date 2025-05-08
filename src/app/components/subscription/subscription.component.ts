import { Component, OnInit } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { SubscriptionService } from '../../services/subscription.service';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { Router } from '@angular/router';
import { BehaviorSubject } from 'rxjs';
import { StorageService } from 'src/app/auth/services/storage/storage.service';
import { CommonModule } from '@angular/common';
import { MatIconModule } from '@angular/material/icon';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';
import { MatTooltipModule } from '@angular/material/tooltip';
import { RouterLink } from '@angular/router';

interface SubscriptionPlan {
  id: number;
  name: string;
  monthlyPrice: number;
  features: string[];
  excludedFeatures: string[];
  isPopular: boolean;
}

interface SubscriptionOptions {
  damageProtection: boolean;
  chargingStations: boolean;
  cleaningService: boolean;
}

interface Vehicle {
  id: number;
  brand: string;
  model: string;
  matricule: string;
}

@Component({
  selector: 'app-subscription',
  templateUrl: './subscription.component.html',
  styleUrls: ['./subscription.component.css'],
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    MatIconModule,
    MatProgressSpinnerModule,
    MatSnackBarModule,
    MatTooltipModule,
    RouterLink
  ]
})
export class SubscriptionComponent implements OnInit {
  currentStep = 1;
  subscriptionForm: FormGroup;
  plans = new BehaviorSubject<SubscriptionPlan[]>([
    {
      id: 1,
      name: 'Basique',
      monthlyPrice: 89,
      features: [
        'Accès à tous les parkings',
        '5 heures de stationnement par jour',
        'Réservation 24h à l\'avance'
      ],
      excludedFeatures: [
        'Places premium',
        'Service de voiturier'
      ],
      isPopular: false
    },
    {
      id: 2,
      name: 'Premium',
      monthlyPrice: 149,
      features: [
        'Accès à tous les parkings',
        'Stationnement illimité',
        'Réservation 72h à l\'avance',
        'Accès aux places premium'
      ],
      excludedFeatures: [
        'Service de voiturier'
      ],
      isPopular: true
    },
    {
      id: 3,
      name: 'Entreprise',
      monthlyPrice: 269,
      features: [
        'Accès à tous les parkings',
        'Stationnement illimité',
        'Réservation 7 jours à l\'avance',
        'Accès aux places premium',
        'Service de voiturier inclus'
      ],
      excludedFeatures: [],
      isPopular: false
    }
  ]);
  
  selectedPlan = new BehaviorSubject<number>(2);
  billingType = new BehaviorSubject<'monthly' | 'annual'>('monthly');
  paymentMethod = new BehaviorSubject<'card' | 'd17'>('card');
  options = new BehaviorSubject<SubscriptionOptions>({
    damageProtection: false,
    chargingStations: false,
    cleaningService: false
  });
  saveCard = new BehaviorSubject<boolean>(false);
  isLoading = false;
  paymentInitiated = false;
  paymentUrl: string | null = null;
  vehicles = new BehaviorSubject<Vehicle[]>([]);
  selectedVehicleId = new BehaviorSubject<number | null>(null);
  faqOpen: boolean[] = [false, false, false, false];

  constructor(
    private fb: FormBuilder,
    private subscriptionService: SubscriptionService,
    private storageService: StorageService,
    private snackBar: MatSnackBar,
    private router: Router
  ) {
    this.subscriptionForm = this.fb.group({
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern(/^\d{8}$/)]],
      vehicleId: [null, Validators.required], // Comment out Validators.required for debugging: [null]
      cardName: [''],
      cardNumber: [''],
      cardExpiry: [''],
      cardCvv: [''],
      damageProtection: [false],
      chargingStations: [false],
      cleaningService: [false]
    });
    this.updatePaymentValidators(); // Set initial validators
  }

  ngOnInit(): void {
    if (!this.storageService.isLoggedIn()) {
      this.snackBar.open('Veuillez vous connecter pour continuer.', 'Fermer', { duration: 5000 });
      this.router.navigate(['/login']);
      return;
    }

    this.subscriptionService.getUserProfile().subscribe({
      next: (user) => {
        this.subscriptionForm.patchValue({
          firstName: user.firstName || '',
          lastName: user.lastName || '',
          email: user.email || '',
          phone: user.phone || ''
        });
        this.vehicles.next(user.vehicles || []);
        console.log('Vehicles:', this.vehicles.value); // Debug vehicles
        if (user.vehicles && user.vehicles.length > 0) {
          this.selectedVehicleId.next(user.vehicles[0].id);
          this.subscriptionForm.get('vehicleId')?.setValue(user.vehicles[0].id);
        } else {
          this.snackBar.open('Aucun véhicule trouvé. Veuillez en ajouter un dans votre profil.', 'Fermer', { duration: 5000 });
        }
      },
      error: (err) => {
        this.snackBar.open('Impossible de charger le profil. Veuillez entrer les informations manuellement.', 'Fermer', { duration: 5000 });
        // Fallback mock data for debugging
        this.vehicles.next([{ id: 1, brand: 'Toyota', model: 'Corolla', matricule: 'ABC123' }]);
        this.subscriptionForm.get('vehicleId')?.setValue(1);
      }
    });

    // Update validators when payment method changes
    this.paymentMethod.subscribe(method => {
      this.updatePaymentValidators(method);
    });
  }

  updatePaymentValidators(method: 'card' | 'd17' = this.paymentMethod.value): void {
    const cardControls = ['cardName', 'cardNumber', 'cardExpiry', 'cardCvv'];
    cardControls.forEach(control => {
      const validators = method === 'card' ? [Validators.required] : [];
      if (control === 'cardNumber') validators.push(Validators.pattern(/^\d{16}$/));
      if (control === 'cardExpiry') validators.push(Validators.pattern(/^(0[1-9]|1[0-2])\/\d{2}$/));
      if (control === 'cardCvv') validators.push(Validators.pattern(/^\d{3}$/));
      this.subscriptionForm.get(control)?.setValidators(validators);
      this.subscriptionForm.get(control)?.updateValueAndValidity({ emitEvent: false });
      if (method === 'd17') {
        this.subscriptionForm.get(control)?.setValue('');
      }
    });
    this.subscriptionForm.updateValueAndValidity();
  }

  debugForm(): void {
    console.log('Form Valid:', this.subscriptionForm.valid);
    console.log('Form Errors:', this.subscriptionForm.errors);
    Object.keys(this.subscriptionForm.controls).forEach(key => {
      const control = this.subscriptionForm.get(key);
      console.log(`${key}:`, {
        value: control?.value,
        valid: control?.valid,
        errors: control?.errors,
        touched: control?.touched
      });
    });
  }

  toggleBillingType(): void {
    this.billingType.next(this.billingType.value === 'monthly' ? 'annual' : 'monthly');
  }

  selectPlan(planId: number): void {
    this.selectedPlan.next(planId);
  }

  selectPaymentMethod(method: 'card' | 'd17'): void {
    this.paymentMethod.next(method);
  }

  updateOption(option: keyof SubscriptionOptions, event: Event): void {
    const checked = (event.target as HTMLInputElement).checked;
    this.options.next({
      ...this.options.value,
      [option]: checked
    });
    this.subscriptionForm.get(option)?.setValue(checked);
  }

  updateSaveCard(event: Event): void {
    this.saveCard.next((event.target as HTMLInputElement).checked);
  }

  selectVehicle(vehicleId: number): void {
    this.selectedVehicleId.next(vehicleId);
    this.subscriptionForm.get('vehicleId')?.setValue(vehicleId);
  }

  calculatePrice(monthlyPrice: number): number {
    return this.billingType.value === 'annual' ? Math.round(monthlyPrice * 12 * 0.8) : monthlyPrice;
  }

  calculateAnnualPrice(monthlyPrice: number): number {
    return Math.round(monthlyPrice * 12 * 0.8);
  }

  getSelectedPlanName(): string {
    const plan = this.plans.value.find(p => p.id === this.selectedPlan.value);
    return plan ? plan.name : '';
  }

  getSelectedPlanPrice(): number {
    const plan = this.plans.value.find(p => p.id === this.selectedPlan.value);
    return plan ? this.calculatePrice(plan.monthlyPrice) : 0;
  }

  calculateTotal(): number {
    const plan = this.plans.value.find(p => p.id === this.selectedPlan.value);
    if (!plan) return 0;

    let total = this.calculatePrice(plan.monthlyPrice);
    
    if (this.options.value.damageProtection) total += 15;
    if (this.options.value.chargingStations) total += 24;
    if (this.options.value.cleaningService) total += 45;
    
    return total;
  }

  calculateVAT(): number {
    return Math.round(this.calculateTotal() * 0.2 * 100) / 100;
  }

  calculateTotalWithVAT(): number {
    return Math.round((this.calculateTotal() + this.calculateVAT()) * 100) / 100;
  }

  toggleFAQ(index: number): void {
    this.faqOpen[index] = !this.faqOpen[index];
  }

  nextStep(): void {
    this.debugForm(); // Debug form state
    if (this.currentStep === 1) {
      if (this.vehicles.value.length === 0) {
        this.snackBar.open('Veuillez ajouter un véhicule avant de continuer.', 'Fermer', { duration: 5000 });
        this.router.navigate(['/profile']);
        return;
      }
      this.currentStep = 2;
    } else if (this.currentStep === 2) {
      if (this.subscriptionForm.invalid) {
        this.subscriptionForm.markAllAsTouched();
        this.snackBar.open('Veuillez compléter tous les champs obligatoires.', 'Fermer', { duration: 5000 });
        return;
      }
      this.currentStep = 3;
    }
  }

  submitForm(): void {
    this.debugForm(); // Debug form state
    if (this.subscriptionForm.invalid) {
      this.subscriptionForm.markAllAsTouched();
      this.snackBar.open('Veuillez compléter tous les champs obligatoires.', 'Fermer', { duration: 5000 });
      return;
    }

    this.isLoading = true;
    const plan = this.plans.value.find(p => p.id === this.selectedPlan.value);
    const type = this.billingType.value === 'annual' ? 'YEARLY' : 'MONTHLY';
    const subscriptionTypeMap: { [key: number]: string } = {
      1: 'BASIC',
      2: 'PREMIUM',
      3: 'ENTERPRISE'
    };

    if (!plan) {
      this.snackBar.open('Veuillez sélectionner un forfait.', 'Fermer', { duration: 5000 });
      this.isLoading = false;
      return;
    }

    const userProfile = {
      firstName: this.subscriptionForm.get('firstName')?.value,
      lastName: this.subscriptionForm.get('lastName')?.value,
      email: this.subscriptionForm.get('email')?.value,
      phone: this.subscriptionForm.get('phone')?.value,
      vehicles: this.vehicles.value.map(v => ({ id: v.id, brand: v.brand, model: v.model, matricule: v.matricule }))
    };

    this.subscriptionService.updateUserProfile(userProfile).subscribe({
      next: () => {},
      error: (err) => {
        this.snackBar.open('Impossible de mettre à jour le profil. La souscription continue.', 'Fermer', { duration: 5000 });
      }
    });

    const subscriptionType = subscriptionTypeMap[plan.id];
    this.subscriptionService.subscribe(subscriptionType, type).subscribe({
      next: (response: { redirectUrl: string }) => {
        this.isLoading = false;
        this.paymentInitiated = true;
        this.paymentUrl = response.redirectUrl || null;
        this.snackBar.open('Souscription initiée. Redirigez vers le paiement.', 'OK', { duration: 5000 });
        if (this.paymentUrl) {
          window.open(this.paymentUrl, '_blank');
        }
      },
      error: (err) => {
        this.isLoading = false;
        const message = err.status === 401 ? 'Session expirée. Veuillez vous reconnecter.' : 'Erreur lors de la souscription.';
        this.snackBar.open(message, 'Fermer', { duration: 5000 });
        if (err.status === 401) {
          this.storageService.logout();
          this.router.navigate(['/login']);
        }
      }
    });
  }
}