import { Component } from '@angular/core';
import { CommonModule } from '@angular/common'; // ✅ Ajouté pour ngClass
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators, FormsModule } from '@angular/forms';
import { AuthService } from '../../services/auth/auth.service';
import { HttpClientModule } from '@angular/common/http';
import { Router } from '@angular/router';
import { NzMessageService } from 'ng-zorro-antd/message';

@Component({
  selector: 'app-auth',
  standalone: true,
  imports: [
    CommonModule, // ✅ Nécessaire pour ngClass
    ReactiveFormsModule, // ✅ Nécessaire pour formGroup
    FormsModule, // ✅ Nécessaire pour [(ngModel)]
    HttpClientModule
  ],
  templateUrl: './auth.component.html',
  styleUrls: ['./auth.component.css']
})
export class AuthComponent {
  isSignUp = false;
  loginForm: FormGroup;
  signupForm: FormGroup;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private message: NzMessageService,
    private router: Router
  ) {
    // Formulaire Login
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });

    // Formulaire SignUp
    this.signupForm = this.fb.group({
      firstName: ['', [Validators.required, Validators.maxLength(50)]],
      lastName: ['', [Validators.required, Validators.maxLength(50)]],
      email: ['', [Validators.required, Validators.email, Validators.maxLength(50)]],
      phone: ['', [Validators.required, Validators.pattern(/^(?:\+?\d{1,3}[- ]?)?\d{8,15}$/)]],
      password: ['', [Validators.required, Validators.minLength(6), Validators.maxLength(120)]],
      confirmPassword: ['', Validators.required],
    }, { validators: this.passwordMatchValidator });
  }

  // Validation des mots de passe
  passwordMatchValidator(group: FormGroup) {
    const password = group.get('password')?.value;
    const confirmPassword = group.get('confirmPassword')?.value;
    return password === confirmPassword ? null : { mismatch: true };
  }

  // Changer entre Login et SignUp
  toggleForm() {
    this.isSignUp = !this.isSignUp;
  }

  // Connexion
  login() {
    if (this.loginForm.invalid) {
      this.message.error("Veuillez remplir tous les champs correctement.");
      return;
    }
  
    const loginData = this.loginForm.value;
    this.authService.login(loginData).subscribe({
      next: (response: any) => {
        // Stocker le token et l'ID utilisateur
        localStorage.setItem('token', response.token);
        localStorage.setItem('userId', response.userId);  // Stockage de l'ID de l'utilisateur
        this.message.success("Connexion réussie !");
        this.router.navigate(['/user-dashboard']);
      },
      error: () => {
        this.message.error("Échec de la connexion. Vérifiez vos identifiants.");
      }
    });
  }
  

  // Inscription
  register() {
    if (this.signupForm.invalid) {
      this.message.error("Veuillez corriger les erreurs du formulaire.");
      return;
    }

    const { confirmPassword, ...userData } = this.signupForm.value;
    this.authService.register(userData).subscribe({
      next: (res) => {
        if (res.message?.includes("User registered successfully")) {
          this.message.success("Inscription réussie !");
          this.router.navigateByUrl("/login");
        } else {
          this.message.error("Une erreur s'est produite.");
        }
      },
      error: () => {
        this.message.error("Une erreur est survenue lors de l'inscription.");
      }
    });
  }
}
