import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from '../auth/services/auth/auth.service';




@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive,],
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.css']
})
export class NavbarComponent {
 
  constructor(
    public authService: AuthService,
    private router: Router
  ) {}

  navigateTo(route: string): void {
    this.router.navigate([route])
      .then(success => {
        if (!success) {
          console.error('Navigation failed to:', route);
          this.router.navigate(['/error']);
        }
      });
  }
}