import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private isAuthenticatedValue = false;
  private role: string = '';
  private uniqueCode: string = '';

  constructor(private router: Router) {}

  // Méthode pour simuler la connexion
  login(email: string, password: string, role: string, uniqueCode: string): void {
    // Ici vous pouvez vérifier les données avec votre backend
    this.isAuthenticatedValue = true;
    this.role = role;
    this.uniqueCode = uniqueCode;
    console.log('Login effectué avec le code unique:', this.uniqueCode);
  }

  // Vérifier si l'utilisateur est authentifié
  isAuthenticated(): boolean {
    return this.isAuthenticatedValue;
  }

  // Vérifier si l'utilisateur est admin
  isAdmin(): boolean {
    return this.role === 'admin';
  }

  // Getter pour le code unique
  getUniqueCode(): string {
    return this.uniqueCode;
  }
}
