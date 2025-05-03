import { Component, OnInit } from '@angular/core';
import { UserService } from '../../services/user.service';
import { ReservationService } from '../../services/Reservations/reservation.service';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterOutlet, RouterLink } from '@angular/router';

@Component({
  selector: 'app-user-dashboard',
  standalone: true,
  templateUrl: './user-dashboard.component.html',
  styleUrls: ['./user-dashboard.component.css'],
  imports: [ReactiveFormsModule, RouterOutlet, RouterLink]
})
export class UserDashboardComponent implements OnInit { // Nom corrigé
  profileForm!: FormGroup;
  reservations: any[] = [];
  userId = 1;

  constructor(
    private userService: UserService,
    private reservationService: ReservationService,
    private fb: FormBuilder
  ) {}

  ngOnInit() {
    // Formulaire de modification du profil
    this.profileForm = this.fb.group({
      nom: [''],
      prenom: [''],
      email: [''],
      numPhone: [''],
      password: ['', [Validators.minLength(6)]],  // Validation de longueur pour le mot de passe
      confirmPassword: ['', [Validators.minLength(6)]]
    });

    // Charger les informations du profil et l'historique des réservations
    this.loadUserProfile();
    this.loadUserReservations();
  }

  loadUserProfile() {
    this.userService.getUserProfile().subscribe((data) => {

      this.profileForm.patchValue(data);
    });
  }

  loadUserReservations() {
    const observable = this.reservationService.createReservations(this.reservations);

if (observable) {
  observable.subscribe(response => {
    console.log("Réservation réussie", response);
  }, error => {
    console.error("Erreur lors de la réservation", error);
  });
} else {
  console.error("L'appel à createReservation() n'a pas retourné d'Observable.");
}

  }

  updateProfile() {
    this.userService.updateUserProfile(this.profileForm.value).subscribe(() => {

      alert('Profil mis à jour avec succès !');
    });
  }
}
