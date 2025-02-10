import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { NgIf } from '@angular/common';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-sign-in',
  standalone: true,
  imports: [FormsModule, RouterModule, NgIf],
  templateUrl: './sign-in.component.html',
})
export class SignInComponent {
  email: string = '';
  password: string = '';
  role: string = '';
  adminCode: string = '';
  userCode: string = '';

  private readonly ADMIN_SECRET_CODE = 'ADMIN123';
  private readonly USER_SECRET_CODE = 'USER123';

  constructor(private router: Router) {}

  signIn() {
    if (this.role === 'admin') {
      if (this.adminCode !== this.ADMIN_SECRET_CODE) {
        alert('Code Admin incorrect. Veuillez réessayer.');
        return;
      }
      alert('Connexion réussie en tant qu\'Admin.');
      this.router.navigate(['/admin-dashboard']);
    } else if (this.role === 'user') {
      if (this.userCode !== this.USER_SECRET_CODE) {
        alert('Code Utilisateur incorrect. Veuillez réessayer.');
        return;
      }
      alert('Connexion réussie en tant qu\'Utilisateur.');
      this.router.navigate(['/user-dashboard']);
    } else {
      alert('Veuillez choisir un rôle valide.');
    }
  }
}
