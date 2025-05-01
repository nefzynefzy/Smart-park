import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { AuthGuard } from './core/guards/auth.guard/auth.guard.component';


export const appRoutes: Routes = [
  {
    path: '',
    redirectTo: 'auth',
    pathMatch: 'full'
  },
  {
    path: 'auth',
    loadComponent: () => import('./auth/components/auth/auth.component').then(m => m.AuthComponent)
  },
  {
    path: '',
    loadComponent: () => import('./layout/layout.component').then(m => m.LayoutComponent),
    children: [
      // Routes Admin
      {
        path: 'admin-dashboard',
        loadComponent: () => import('./dashboard-admin/admin-dashboard.component').then(m => m.AdminDashboardComponent),
        canActivate: [AuthGuard],
        children: [
          {
            path: 'analytics',
            loadComponent: () => import('./dashboard-admin/components/analytics/analytics.component').then(m => m.AnalyticsComponent)
          },
          {
            path: 'users',
            loadComponent: () => import('./dashboard-admin/components/user-management/user-management.component').then(m => m.UserManagementComponent)
          },
          {
            path: 'settings',
            loadComponent: () => import('./dashboard-admin/components/parking-settings/parking-settings.component').then(m => m.ParkingSettingsComponent)
          },
          {
            path: '',
            redirectTo: 'analytics',
            pathMatch: 'full'
          }
        ]
      },
      // Routes Utilisateur
      {
        path: 'user-dashboard',
        loadComponent: () => import('./components/user-dashboard/user-dashboard.component').then(m => m.DashboardComponent),
        canActivate: [AuthGuard]
      },
      {
        path: 'profile',
        loadComponent: () => import('./components/user-dashboard/profile/profile.component').then(m => m.ProfileComponent),
        canActivate: [AuthGuard]
      },
      {
        path: 'reservations',
        loadComponent: () => import('./components/user-dashboard/reservations/reservations.component').then(m => m.ReservationsComponent),
        canActivate: [AuthGuard]
      },
      {
        path: 'abonnement',
        loadComponent: () => import('./components/user-dashboard/abonnement/abonnement.component').then(m => m.AbonnementComponent),
        canActivate: [AuthGuard]
      }
    ]
  },
  {
    path: '**',
    redirectTo: 'auth'
  }
];

@NgModule({
  imports: [RouterModule.forRoot(appRoutes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }