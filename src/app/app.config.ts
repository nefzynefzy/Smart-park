import { ApplicationConfig, importProvidersFrom } from '@angular/core';
import { provideRouter, withComponentInputBinding } from '@angular/router';
import { provideHttpClient, withInterceptors } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';
import { MatNativeDateModule } from '@angular/material/core';
import { en_US, provideNzI18n } from 'ng-zorro-antd/i18n';
import { NzMessageService } from 'ng-zorro-antd/message';
import { routes } from './app.routes';
import { AuthService } from './auth/services/auth/auth.service';
export const appConfig: ApplicationConfig = {
  providers: [
    AuthService,
    // Configuration du router avec les routes
    provideRouter(
      routes,
      withComponentInputBinding() // Activation des Inputs de routage
    ),
    
    // Configuration HTTP
    provideHttpClient(
      withInterceptors([]) // Ajouter les intercepteurs si nécessaire
    ),
    
    // Animations
    provideAnimations(),
    
    // Modules externes
    importProvidersFrom(
      MatNativeDateModule, // Pour Angular Material DatePicker
    ),
    
    // Configuration de NG-ZORRO
    provideNzI18n(en_US),
    NzMessageService, // Service plutôt que module
    
    // Ajouter d'autres providers ici...
  ]
};