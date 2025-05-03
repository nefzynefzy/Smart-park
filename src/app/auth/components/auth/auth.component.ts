import { Component } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth/auth.service';
import { CommonModule } from '@angular/common';
import { NzMessageService } from 'ng-zorro-antd/message';

@Component({
  selector: 'app-auth',
  templateUrl: './auth.component.html',
  styleUrls: ['./auth.component.css'],
  standalone: true,
  imports: [
    CommonModule, 
    ReactiveFormsModule,
  ]

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
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });

    this.signupForm = this.fb.group({
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', [Validators.required, Validators.email]],
      phone: ['', [Validators.required, Validators.pattern(/^\d{10}$/)]],
      password: ['', [Validators.required, Validators.minLength(6)]],
      confirmPassword: ['', Validators.required]
    }, { validators: this.passwordMatchValidator });
  }

  passwordMatchValidator(group: FormGroup): { [key: string]: any } | null {
    return group.get('password')?.value === group.get('confirmPassword')?.value 
      ? null 
      : { mismatch: true };
  }

  toggleForm(): void {
    this.isSignUp = !this.isSignUp;
  }

  login(): void {
    if (this.loginForm.invalid) {
      this.message.error('Veuillez remplir correctement le formulaire');
      return;
    }

    this.authService.login(this.loginForm.value).subscribe({
      error: (err) => {
        this.message.error(err.error?.message || 'Erreur de connexion');
      }
    });
  }

  register(): void {
    if (this.signupForm.invalid) {
      this.message.error('Veuillez corriger les erreurs du formulaire');
      return;
    }

    const { confirmPassword, ...userData } = this.signupForm.value;
    this.authService.register(userData).subscribe({
      next: (res) => {
        if (res.message?.toLowerCase().includes('success')) {
          this.message.success('Inscription réussie !');
          this.isSignUp = false;
        } else {
          this.message.success('Compte créé avec succès !');
        }
      },
      error: (err) => {
        this.message.error(err.error?.message || 'Erreur lors de l\'inscription');
      }
    });
  }
}