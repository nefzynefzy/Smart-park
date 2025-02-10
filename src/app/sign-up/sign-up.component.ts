import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { RouterModule } from '@angular/router';

@Component({
  selector: 'app-sign-up',
  standalone: true,
  imports: [FormsModule, RouterModule],
  templateUrl: './sign-up.component.html',
})
export class SignUpComponent {
  firstName: string = '';
  lastName: string = '';
  email: string = '';
  username: string = '';
  phone: string = '';
  password: string = '';
  confirmPassword: string = '';

  signUp() {
    if (this.password !== this.confirmPassword) {
      alert("Les mots de passe ne correspondent pas !");
      return;
    }
    console.log('Inscription réussie avec :', {
      firstName: this.firstName,
      lastName: this.lastName,
      email: this.email,
      username: this.username,
      phone: this.phone,
    });
  }
}
