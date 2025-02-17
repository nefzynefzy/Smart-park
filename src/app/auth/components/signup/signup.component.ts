import { Component } from '@angular/core';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { AuthService } from '../../services/auth/auth.service';
import { HttpClientModule } from '@angular/common/http';
import { Router, RouterModule } from '@angular/router';
import { NzMessageService } from 'ng-zorro-antd/message';

@Component({
  selector: 'app-signup',
  standalone: true,
  imports: [ReactiveFormsModule, HttpClientModule ,RouterModule],
  templateUrl: './signup.component.html',
  styleUrls: ['./signup.component.css']
})
export class SignupComponent {
  signupForm: FormGroup;

  constructor(
    private fb: FormBuilder,
    private authService: AuthService,
    private message: NzMessageService,
    private router: Router
  ) {
    this.signupForm = this.fb.group({
      firstName: ['', [Validators.required, Validators.maxLength(50)]],
      lastName: ['', [Validators.required, Validators.maxLength(50)]],
      email: ['', [Validators.required, Validators.email, Validators.maxLength(50)]],
      phone: ['', [Validators.required, Validators.pattern(/^(?:\+?\d{1,3}[- ]?)?\d{8,15}$/)]],
      password: ['', [Validators.required, Validators.minLength(6), Validators.maxLength(120)]],
      confirmPassword: ['', Validators.required],
    }, { validators: this.passwordMatchValidator });
  }

  passwordMatchValidator(group: FormGroup) {
    const password = group.get('password')?.value;
    const confirmPassword = group.get('confirmPassword')?.value;
    return password === confirmPassword ? null : { mismatch: true };
  }

  register() {
    if (this.signupForm.invalid) {
      this.message.error("Veuillez corriger les erreurs dans le formulaire", { nzDuration: 5000 });
      return;
    }
  
    const { confirmPassword, ...userData } = this.signupForm.value;
  
    this.authService.register(userData).subscribe({
      next: (res) => {
        console.log("Réponse de l'API :", res); // Debugging
      
        // Check if the API response contains a success message
        if (res.message && res.message.includes("User registered successfully")) { 
          this.message.success("Inscription réussie", { nzDuration: 5000 });
          this.router.navigateByUrl("/login");
        } else {
          this.message.error("Une erreur s'est produite", { nzDuration: 5000 });
        }
      },      
    });
  }
  
}
