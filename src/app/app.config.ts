import { ApplicationConfig } from '@angular/core';
import { provideRouter } from '@angular/router';
import { provideHttpClient } from '@angular/common/http';
import { provideAnimations } from '@angular/platform-browser/animations';
import { importProvidersFrom } from '@angular/core';
import { MatNativeDateModule } from '@angular/material/core';
import { en_US, provideNzI18n } from 'ng-zorro-antd/i18n';
import { NzMessageModule } from 'ng-zorro-antd/message';

export const appConfig: ApplicationConfig = {
  providers: [
    provideRouter([]),
    provideHttpClient(),
    provideAnimations(),
    importProvidersFrom(MatNativeDateModule),// Correct : importer le module
    importProvidersFrom(NzMessageModule), // Fournir NzMessageModule globalement
    provideNzI18n(en_US)
  ]
};