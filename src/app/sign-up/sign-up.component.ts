import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-sign-up',
  standalone: true,
  imports: [FormsModule, RouterModule],
  templateUrl: './sign-up.component.html'
})
export class SignUpComponent {
  nom: string = '';
  prenom: string = '';
  email: string = '';
  password: string = '';
  cin: string = '';
  age: number | null = null;
  numPhone: string = '';
  poste: string = '';
  role: string = '';

  signUp() {
    console.log('Données utilisateur :', this.nom, this.prenom, this.email, this.role);
  }
}
