import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';
import { SignInComponent } from './app/sign-in/sign-in.component';
import { SignUpComponent } from './app/sign-up/sign-up.component';
import { AdminDashboardComponent } from './app/admin-dashboard/admin-dashboard.component';
import { UserDashboardComponent } from './app/user-dashboard/user-dashboard.component';
import { appRoutes } from './app/app.routes'; // Importation des routes

bootstrapApplication(SignInComponent, {
  providers: [
    provideRouter(appRoutes) // Fournir le routage ici
  ]
});
