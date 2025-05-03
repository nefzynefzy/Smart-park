import { Component, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

interface SubscriptionPlan {
  id: string;
  name: string;
  monthlyPrice: number;
  features: string[];
  excludedFeatures: string[];
  isPopular: boolean;
}

@Component({
  selector: 'app-abonnement',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './abonnement.component.html',
  styleUrls: ['./abonnement.component.scss']
})
export class AbonnementComponent {
  // Données des plans
  plans = signal<SubscriptionPlan[]>([
    {
      id: 'basique',
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
      id: 'premium',
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
      id: 'entreprise',
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

  // États
  selectedPlan = signal<string | null>('premium');
  billingType = signal<'monthly' | 'annual'>('monthly');
  paymentMethod = signal<'card' | 'paypal' | 'apple' | 'google'>('card');
  personalInfo = signal({
    firstName: '',
    lastName: '',
    email: '',
    phone: '',
    carModel: '',
    licensePlate: ''
  });
  options = signal({
    damageProtection: false,
    chargingStations: false,
    cleaningService: false
  });
  cardDetails = signal({
    name: '',
    number: '',
    expiry: '',
    cvv: ''
  });
  saveCard = signal(false);

  // Méthodes utilitaires
  getSelectedPlanName(): string {
    if (!this.selectedPlan()) return 'Aucun forfait sélectionné';
    return this.plans().find(p => p.id === this.selectedPlan())?.name || '';
  }

  getSelectedPlanPrice(): number {
    if (!this.selectedPlan()) return 0;
    const monthlyPrice = this.plans().find(p => p.id === this.selectedPlan())?.monthlyPrice || 0;
    return this.calculatePrice(monthlyPrice);
  }

  calculateAnnualPrice(monthlyPrice: number): number {
    return Math.round(monthlyPrice * 12 * 0.8);
  }

  // Fonctions principales
  toggleBillingType(): void {
    this.billingType.set(this.billingType() === 'monthly' ? 'annual' : 'monthly');
  }

  selectPlan(planId: string): void {
    this.selectedPlan.set(planId);
  }

  selectPaymentMethod(method: 'card' | 'paypal' | 'apple' | 'google'): void {
    this.paymentMethod.set(method);
  }

  calculatePrice(monthlyPrice: number): number {
    return this.billingType() === 'annual' ? this.calculateAnnualPrice(monthlyPrice) / 12 : monthlyPrice;
  }

  calculateTotal(): number {
    const plan = this.plans().find(p => p.id === this.selectedPlan());
    if (!plan) return 0;

    let total = this.calculatePrice(plan.monthlyPrice);
    
    if (this.options().damageProtection) total += 15;
    if (this.options().chargingStations) total += 24;
    if (this.options().cleaningService) total += 45;
    
    return total;
  }

  calculateVAT(): number {
    return Math.round(this.calculateTotal() * 0.2 * 100) / 100;
  }

  calculateTotalWithVAT(): number {
    return Math.round((this.calculateTotal() + this.calculateVAT()) * 100) / 100;
  }

  submitForm(): void {
    console.log('Form submitted', {
      plan: this.selectedPlan(),
      billingType: this.billingType(),
      personalInfo: this.personalInfo(),
      options: this.options(),
      paymentMethod: this.paymentMethod(),
      cardDetails: this.cardDetails(),
      saveCard: this.saveCard()
    });
  }
}