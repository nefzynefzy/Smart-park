import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { AuthService } from 'src/app/auth/services/auth/auth.service';


@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot): boolean {
    // Vérification synchrone renforcée
    const isAuth = this.authService.isAuthenticated();
    const user = this.authService.getUser();
    
    if (!isAuth || !user) {
      this.router.navigate(['/auth'], { 
        queryParams: { returnUrl: this.router.url }
      });
      return false;
    }
  
    const requiredRole = route.data['role'];
    if (requiredRole && user.role !== requiredRole) {
      this.router.navigate(['/access-denied']);
      return false;
    }
  
    return true;
  }}