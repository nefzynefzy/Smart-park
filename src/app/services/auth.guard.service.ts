import { Injectable } from '@angular/core';
import { CanActivate, ActivatedRouteSnapshot, RouterStateSnapshot, Router } from '@angular/router';
import { AuthService } from '../auth/services/auth/auth.service';


@Injectable({ providedIn: 'root' })
export class AuthGuard implements CanActivate {
  constructor(private authService: AuthService, private router: Router) {}

  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean {
   // Temporairement toujours autoriser l'accès
   return true;

   /* Version originale commentée
   if (!this.authService.isAuthenticated()) {
     this.router.navigate(['/auth'], { queryParams: { returnUrl: state.url } });
     return false;
   }

   const expectedRole = route.data['role'];
   if (expectedRole && !this.authService.hasRole(expectedRole)) {
     this.router.navigate(['/access-denied']);
     return false;
   }

   return true;
   */
 }
}