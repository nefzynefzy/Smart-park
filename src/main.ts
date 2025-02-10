import { bootstrapApplication } from '@angular/platform-browser';
import { provideRouter } from '@angular/router';
import { SignInComponent } from './app/auth/components/sign-in/sign-in.component';
import { SignUpComponent } from './app/auth/components/sign-up/sign-up.component';
import { AdminDashboardComponent } from './app/admin-dashboard/admin-dashboard.component';
import { UserDashboardComponent } from './app/user-dashboard/user-dashboard.component';
import { appRoutes } from './app/app.routes';
import { en_US, provideNzI18n } from 'ng-zorro-antd/i18n';
import { registerLocaleData } from '@angular/common';
import en from '@angular/common/locales/en';
import { FormsModule } from '@angular/forms';
import { importProvidersFrom } from '@angular/core';
import { provideAnimationsAsync } from '@angular/platform-browser/animations/async';
import { provideHttpClient } from '@angular/common/http';

registerLocaleData(en); // Importation des routes

bootstrapApplication(SignInComponent, {
  providers: [
    provideRouter(appRoutes), provideNzI18n(en_US), importProvidersFrom(FormsModule), provideAnimationsAsync(), provideHttpClient() // Fournir le routage ici
  ]
});
