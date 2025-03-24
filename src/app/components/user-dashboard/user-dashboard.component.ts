import { Component, OnInit } from '@angular/core';
import { UserService } from '../../services/user.service';;
import { ReservationService } from '../../services/Reservations/reservation.service';  // Service pour les réservations
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';

@Component({
  selector: 'app-dashboard',
  standalone: true,  // Composant autonome
  templateUrl: './user-dashboard.component.html',
  styleUrls: ['./user-dashboard.component.css'],
  imports: [ReactiveFormsModule]  // Assurer que ReactiveFormsModule est importé
})
export class DashboardComponent implements OnInit {
  profileForm!: FormGroup;
  reservations: any[] = [];  // Liste des réservations de l'utilisateur
  userId = 1;  // Remplace avec l'ID de l'utilisateur connecté

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
    const observable = this.reservationService.createReservation(this.reservations);
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
