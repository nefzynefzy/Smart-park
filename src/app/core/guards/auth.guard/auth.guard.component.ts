import { Injectable } from '@angular/core';
import { CanActivate, Router, ActivatedRouteSnapshot } from '@angular/router';
import { AuthService } from '../../../auth/services/auth/auth.service';


@Injectable({
  providedIn: 'root'
})
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(route: ActivatedRouteSnapshot): boolean {
    // Vérifier si l'utilisateur est authentifié
    if (!this.authService.isAuthenticated()) {
      this.router.navigate(['/auth']);
      return false;
    }

    // Vérifier le rôle pour les routes protégées
    const isAdminRoute = route.routeConfig?.path?.includes('admin-dashboard');
    const isAdmin = this.authService.isAdmin();

    if (isAdminRoute && !isAdmin) {
      // Si la route est admin et que l'utilisateur n'est pas admin, rediriger vers user-dashboard
      this.router.navigate(['/user-dashboard']);
      return false;
    }

    return true;
  }
}