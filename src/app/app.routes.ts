import { Routes } from '@angular/router';
import { AdminDashboardComponent } from './components/admin-dashboard/admin-dashboard.component';
import { DashboardComponent } from './components/user-dashboard/user-dashboard.component';
import { AuthComponent } from './auth/components/auth/auth.component';
import { ProfileComponent } from './components/profile/profile.component';
import { ReservationComponent } from './components/reservations/reservations.component';
import { AbonnementComponent } from './components/abonnement/abonnement.component';
import { AbonnementFormComponent } from './components/abonnement-form/abonnement-form.component';


export const appRoutes: Routes = [
  { path: '', redirectTo: '/auth', pathMatch: 'full' },

  // Auth page (sans navbar)
  { path: 'auth', component: AuthComponent },

  // Toutes les autres pages avec navbar via le layout
  {
    path: '',
    
    children: [
      { path: 'admin-dashboard', component: AdminDashboardComponent },
      { path: 'user-dashboard', component: DashboardComponent },
      { path: 'profile', component: ProfileComponent },
      { path: 'reservations', component: ReservationComponent },
      { path: 'abonnement', component: AbonnementComponent },
      { path: 'souscrire/:type', component: AbonnementFormComponent },
    ],
  },
];
