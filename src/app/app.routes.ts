import { Routes } from '@angular/router';
import { AdminDashboardComponent } from './components/admin-dashboard/admin-dashboard.component';
import { DashboardComponent } from './components/user-dashboard/user-dashboard.component';
import { AuthComponent } from './auth/components/auth/auth.component';
import { ProfileComponent } from './components/profile/profile.component';
import { ReservationsComponent } from './components/reservations/reservations.component';



export const appRoutes: Routes = [
  { path: '', redirectTo: '/auth', pathMatch: 'full' },
  { path: 'auth', component: AuthComponent },
  
  { path: 'admin-dashboard', component: AdminDashboardComponent },
  { path: 'user-dashboard', component: DashboardComponent },
  { path: 'profile', component: ProfileComponent },
  { path: 'reservations', component: ReservationsComponent }
];
