import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';

@Component({
  selector: 'app-sign-in',
  standalone: true,
  imports: [FormsModule, RouterModule],
  templateUrl: './sign-in.component.html',
})
export class SignInComponent {
  email: string = '';
  password: string = '';

  constructor(private router: Router) {}

  signIn() {
    if (this.email && this.password) {
      // Simulation de connexion réussie
      alert('Connexion réussie');
      this.router.navigate(['/dashboard']); // Redirection après connexion
    } else {
      alert('Veuillez remplir tous les champs.');
    }
  }
}
