import { Component, OnInit } from '@angular/core';
import { UserService } from '../../services/user.service';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormGroup, FormControl } from '@angular/forms';


@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  standalone: true,
  imports: [CommonModule,ReactiveFormsModule],

  styleUrls: ['./profile.component.css']
})
export class ProfileComponent implements OnInit {
updateProfile() {
throw new Error('Method not implemented.');
}
  user: any = {};  // Stocke les infos de l'utilisateur
  profileForm!: FormGroup;
reservations: any;

  constructor(private userService: UserService) {}

  ngOnInit(): void {
    this.loadUserProfile();
  }

  loadUserProfile(): void {
    this.userService.getUserProfile().subscribe(
      data => {
        this.user = data;
      },
      error => {
        console.error('Erreur de récupération du profil:', error);
      }
    );
  }
}
