import { Component, OnInit } from '@angular/core';
import { UserService } from '../../services/user.service';

@Component({
  selector: 'app-reservations',
  templateUrl: './reservations.component.html',
  styleUrls: ['./reservations.component.css']
})
export class ReservationsComponent implements OnInit {
  reservations: any[] = [];
  userId = 1; // 🔹 Remplace avec l'ID de l'utilisateur connecté

  constructor(private userService: UserService) {}

  ngOnInit() {
    this.userService.getUserReservations(this.userId).subscribe((data) => {
      this.reservations = data;
    });
  }
}
