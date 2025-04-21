import { FormGroup, FormBuilder, Validators } from '@angular/forms';
import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-reservation',
  templateUrl: './reservations.component.html',
  styleUrls: ['./reservations.component.css'],
})
export class ReservationComponent {
  reservationForm: FormGroup;
  currentStep = 1;
  availablePlaces = [
    { name: 'Place 1', type: 'premium', price: 20, selected: false, reserved: false },
    { name: 'Place 2', type: 'standard', price: 15, selected: false, reserved: false },
    // Ajoute d'autres places ici
  ];
  placeSelected = false;

  constructor(private fb: FormBuilder) {
    // Initialisation du formulaire
    this.reservationForm = this.fb.group({
      date: ['', Validators.required],
      heureDebut: ['', Validators.required],
      heureFin: ['', Validators.required],
      vehicle: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern('[0-9]{8}')]]
    });
  }

  // Pour gérer la sélection des places
  selectPlace(place: any) {
    place.selected = !place.selected;
    this.placeSelected = this.availablePlaces.some(p => p.selected);  // Mise à jour de placeSelected
  }

  nextStep() {
    if (this.currentStep < 3) {
      this.currentStep++;
    }
  }

  prevStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
    }
  }

  get calculatedMontant() {
    const selectedPlace = this.availablePlaces.find(p => p.selected);
    if (selectedPlace) {
      const startTime = this.reservationForm.get('heureDebut')?.value;
      const endTime = this.reservationForm.get('heureFin')?.value;
      const duration = this.calculateDuration(startTime, endTime);
      return selectedPlace.price * duration;
    }
    return 0;
  }

  calculateDuration(start: string, end: string): number {
    const startDate = new Date(`1970-01-01T${start}:00`);
    const endDate = new Date(`1970-01-01T${end}:00`);
    return (endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60); // Durée en heures
  }

  submitReservation() {
    // Soumettre la réservation ici
  }
}
