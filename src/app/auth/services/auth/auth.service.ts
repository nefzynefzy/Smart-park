import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, tap } from 'rxjs';
import { Router } from '@angular/router';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = 'http://localhost:8082/parking/api/auth';

  constructor(private http: HttpClient, private router: Router) {}

  // Connexion
  login(credentials: { email: string; password: string }): Observable<any> {
    return this.http.post(`${this.apiUrl}/signin`, credentials).pipe(
      tap((response: any) => {
        // Stocker le token et les données utilisateur
        if (response.token) {
          localStorage.setItem('token', response.token);
          localStorage.setItem('user', JSON.stringify({
            id: response.id,
            email: response.email,
            role: response.role // Supposons que l'API retourne un champ 'role' (par exemple, 'ADMIN' ou 'USER')
          }));
        }
      })
    );
  }

  // Inscription
  register(userData: any): Observable<any> {
    return this.http.post(`${this.apiUrl}/signup`, userData);
  }

  // Déconnexion
  logout(): void {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    this.router.navigate(['/auth']);
  }

  // Vérifier si l'utilisateur est authentifié
  isAuthenticated(): boolean {
    return !!localStorage.getItem('token');
  }

  // Vérifier si l'utilisateur est un administrateur
  isAdmin(): boolean {
    const user = JSON.parse(localStorage.getItem('user') || '{}');
    return user.role === 'ADMIN'; // Ajustez selon le format de votre API (par exemple, 'admin', 'ADMIN', etc.)
  }

  // Obtenir les données de l'utilisateur
  getUser(): any {
    return JSON.parse(localStorage.getItem('user') || '{}');
  }
}