import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';


@Component({
  selector: 'app-profile',
  templateUrl: './profile.component.html',
  styleUrls: ['./profile.component.css'],
  standalone: true,  // Cela indique que c'est un composant autonome
  imports: [FormsModule]
})
export class ProfileComponent {
  isEditing: boolean = false; // 🔴 Caché au début

  user = {
    email: 'user@email.com',
    phone: '+216 12 345 678',
    vehicle: 'Citroën C3'
  };

  toggleEdit() {
    this.isEditing = !this.isEditing;
  }

  saveChanges() {
    this.isEditing = false; // 🔴 Cache le formulaire après sauvegarde
  }
}
