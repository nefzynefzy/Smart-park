import { Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard/auth.guard.component';

export const routes: Routes = [
  { 
    path: 'auth',
    loadComponent: () => import('./auth/components/auth/auth.component').then(m => m.AuthComponent),
    data: { hideNavbar: true }
  },
  {
    path: 'app',
    canActivate: [AuthGuard],
    loadComponent: () => import('./layout/layout.component').then(m => m.LayoutComponent),
    children: [
      {
        path: 'user/dashboard',
        data: { role: 'USER' },
        children: [
          { 
            path: '',
            loadComponent: () => import('./components/user-dashboard/user-dashboard.component').then(m => m.UserDashboardComponent)
          },
          { 
            path: 'profile',
            loadComponent: () => import('./components/profile/profile.component').then(m => m.ProfileComponent)
          },
          { 
            path: 'reservations',
            loadComponent: () => import('./components/reservations/reservations.component').then(m => m.ReservationsComponent)
          },
          { 
            path: 'abonnements',
            loadComponent: () => import('./components/abonnement/abonnement.component').then(m => m.AbonnementComponent)
          },
          { path: '**', redirectTo: '' }
        ]
      },
      { path: '**', redirectTo: 'user/dashboard' }
    ]
  },
  { path: '**', redirectTo: 'auth' }
];
