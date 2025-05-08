import { Component } from '@angular/core';
import { RouterOutlet } from '@angular/router';

@Component({
  selector: 'app-layout',
  standalone: true,
  imports: [RouterOutlet],
  template: `
    <div class="content">
      <router-outlet></router-outlet>
    </div>
  `,
  styles: [`
    .content { 
      padding-top: 80px;
      min-height: 100vh;
    }
  `]
})
export class LayoutComponent {}