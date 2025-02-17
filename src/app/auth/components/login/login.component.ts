import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink, RouterModule } from '@angular/router';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [FormsModule, RouterModule, RouterLink],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent {
  email: string = '';
  password: string = '';

  constructor(private router: Router, private http: HttpClient) {}

  Login() {
    if (this.email && this.password) {
      const loginData = { email: this.email, password: this.password };

      this.http.post('http://localhost:8082/parking/api/auth/signin', loginData).subscribe(
        (response: any) => {
          localStorage.setItem('token', response.token); // Store JWT token
          alert('Connexion réussie');
          this.router.navigate(['/user-dashboard']); // Redirect after login
        },
        (error) => {
          alert('Échec de la connexion. Vérifiez vos identifiants.');
          console.error(error);
        }
      );
    } else {
      alert('Veuillez remplir tous les champs.');
    }
  }
}
