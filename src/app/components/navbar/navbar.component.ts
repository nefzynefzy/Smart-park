import { Component } from '@angular/core';
import { CommonModule } from '@angular/common'; // ✅ Import de CommonModule pour ngClass
import { RouterModule } from '@angular/router';
@Component({
  selector: 'app-navbar',
  standalone: true,
  imports: [CommonModule, RouterModule], // ✅ Ajout du module
  templateUrl: './navbar.component.html',
  styleUrls: ['./navbar.component.css']
})
export class NavbarComponent {
  menuOpen = false;

  toggleMenu() {
    this.menuOpen = !this.menuOpen;
  }
}
