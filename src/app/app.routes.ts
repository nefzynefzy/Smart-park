import { Routes } from '@angular/router';
import { AdminDashboardComponent } from './components/admin-dashboard/admin-dashboard.component';
import { DashboardComponent } from './components/user-dashboard/user-dashboard.component';
import { SignupComponent } from './auth/components/signup/signup.component';
import { LoginComponent } from './auth/components/login/login.component';
import { ProfileComponent } from './components/profile/profile.component';
import { ReservationsComponent } from './components/reservations/reservations.component';



export const appRoutes: Routes = [
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'signup', component: SignupComponent },
  { path: 'admin-dashboard', component: AdminDashboardComponent },
  { path: 'user-dashboard', component: DashboardComponent },
  { path: 'profile', component: ProfileComponent },
  { path: 'reservations', component: ReservationsComponent }
];
