import { Component, OnInit } from '@angular/core';
import { UserService } from '../../services/user.service';
import { ReservationService } from '../../services/Reservations/reservation.service';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterOutlet, RouterLink } from '@angular/router';
import { Reservation } from '../../models/reservation.model';

@Component({
  selector: 'app-user-dashboard',
  standalone: true,
  templateUrl: './user-dashboard.component.html',
  styleUrls: ['./user-dashboard.component.css'],
  imports: [ReactiveFormsModule, RouterOutlet, RouterLink]
})
export class UserDashboardComponent implements OnInit {
  profileForm!: FormGroup;
  reservations: Reservation[] = [];
  userId = 1;

  constructor(
    private userService: UserService,
    private reservationService: ReservationService,
    private fb: FormBuilder
  ) {}

  ngOnInit() {
    this.initializeForm();
    this.loadUserProfile();
    this.loadUserReservations();
  }

  initializeForm() {
    this.profileForm = this.fb.group({
      nom: [''],
      prenom: [''],
      email: ['', [Validators.email]],
      numPhone: [''],
      password: ['', [Validators.minLength(6)]],
      confirmPassword: ['', [Validators.minLength(6)]]
    });
  }

  loadUserProfile() {
    this.userService.getUserProfile().subscribe({
      next: (data) => {
        this.profileForm.patchValue(data);
      },
      error: (error) => {
        console.error('Error loading profile:', error);
      }
    });
  }

  loadUserReservations() {
    this.reservationService.getUserReservations(this.userId).subscribe({
      next: (reservations: Reservation[]) => {
        this.reservations = reservations;
      },
      error: (error) => {
        console.error('Error loading reservations:', error);
      }
    });
  }

  createNewReservation(reservationData: Reservation) {
    this.reservationService.createReservation(reservationData).subscribe({
      next: (response) => {
        console.log('Reservation created:', response);
        this.loadUserReservations(); // Refresh the list
      },
      error: (error) => {
        console.error('Error creating reservation:', error);
      }
    });
  }

  updateProfile() {
    if (this.profileForm.valid) {
      this.userService.updateUserProfile(this.profileForm.value).subscribe({
        next: () => {
          alert('Profile updated successfully!');
        },
        error: (error) => {
          console.error('Error updating profile:', error);
        }
      });
    } else {
      console.error('Form is invalid');
    }
  }
}