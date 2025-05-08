import { Injectable, Inject, PLATFORM_ID } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, tap } from 'rxjs';
import { isPlatformBrowser } from '@angular/common';

interface AuthResponse {
  message: any;
  token: string;
  id: number;
  firstName: string;
  lastName: string;
  email: string;
  phone: string;
  roles: string[];
}

@Injectable({ providedIn: 'root' })
export class AuthService {
  private apiUrl = 'http://localhost:8082/parking/api/auth';
  private tokenKey = 'token'; // Consistent key for token storage
  constructor(
    private http: HttpClient,
    private router: Router,
    @Inject(PLATFORM_ID) private platformId: Object
  ) {}

  login(credentials: { email: string; password: string }): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/signin`, credentials).pipe(
      tap({
        next: (response) => {
          console.log('Réponse reçue:', response);
          if (isPlatformBrowser(this.platformId)) {
            localStorage.setItem(this.tokenKey, response.token); // Use tokenKey for consistency
            localStorage.setItem('user', JSON.stringify({
              id: response.id,
              role: response.roles.includes('ROLE_ADMIN') ? 'ADMIN' : 'USER'
            }));
            
            // Forcer le rechargement de l'état d'authentification
            setTimeout(() => {
              this.redirectBasedOnRole(response.roles);
            }, 100);
          }
        },
        error: (err) => console.error('Erreur de connexion:', err)
      })
    );
  }

  private handleLoginSuccess(response: AuthResponse): void {
    if (isPlatformBrowser(this.platformId)) {
      localStorage.setItem(this.tokenKey, response.token); // Use tokenKey
      localStorage.setItem('user', JSON.stringify({
        id: response.id,
        firstName: response.firstName,
        lastName: response.lastName,
        email: response.email,
        phone: response.phone,
        role: this.getUserRole(response.roles)
      }));
      this.redirectBasedOnRole(response.roles);
    }
  }

  private getUserRole(roles: string[]): string {
    return roles.includes('ROLE_ADMIN') ? 'ADMIN' : 'USER';
  }

  private redirectBasedOnRole(roles: string[]): void {
    const redirectPath = roles.includes('ROLE_ADMIN') 
      ? '/app/admin/dashboard' 
      : '/app/user/dashboard';
    
    this.router.navigateByUrl(redirectPath, { replaceUrl: true })
      .then(success => {
        if (!success) {
          console.error('Échec de la navigation vers:', redirectPath);
          window.location.href = redirectPath; // Solution de secours
        }
      });
  }

  logout(): void {
    if (isPlatformBrowser(this.platformId)) {
      localStorage.clear();
    }
    this.router.navigate(['/auth']);
  }

  isAuthenticated(): boolean {
    return isPlatformBrowser(this.platformId)
      ? !!localStorage.getItem(this.tokenKey) // Use tokenKey
      : false;
  }

  isAdmin(): boolean {
    return this.getUser().role === 'ADMIN';
  }

  getUser(): any {
    if (!isPlatformBrowser(this.platformId)) return {};
    const userData = localStorage.getItem('user') || '{}';
    return JSON.parse(userData);
  }

  register(userData: any): Observable<AuthResponse> {
    return this.http.post<AuthResponse>(`${this.apiUrl}/signup`, userData);
  }

  getToken(): string | null {
    return isPlatformBrowser(this.platformId) ? localStorage.getItem(this.tokenKey) : null; // Use tokenKey
  }
}