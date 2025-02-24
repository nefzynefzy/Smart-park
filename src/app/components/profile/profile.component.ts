import { Component, OnInit } from '@angular/core';
import { UserService } from '../../services/user.service';

import { FormBuilder, FormGroup, Validators , ReactiveFormsModule} from '@angular/forms';

@Component({
  selector: 'app-profile',
  standalone: true,
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.css'],
  imports: [ReactiveFormsModule],
})
export class ProfileComponent implements OnInit {
  profileForm!: FormGroup;
  userId = 1; // 🔹 Remplace avec l'ID de l'utilisateur connecté

  constructor(private userService: UserService, private fb: FormBuilder) {}

  ngOnInit() {
    this.profileForm = this.fb.group({
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern("^(\\+\\d{1,3}[- ]?)?\\d{8,15}$")]],
      password: ['', [Validators.minLength(6)]]
    });

    this.loadUserProfile();
  }

  loadUserProfile() {
    this.userService.getUserProfile(this.userId).subscribe((data) => {
      this.profileForm.patchValue(data);
    });
  }

  updateProfile() {
    this.userService.updateUserProfile(this.userId, this.profileForm.value).subscribe(() => {
      alert('Profil mis à jour avec succès !');
    });
  }
}
