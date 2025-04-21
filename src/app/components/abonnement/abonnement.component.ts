import { Component, OnInit } from '@angular/core';
import { Abonnement } from '../../models/abonnement.model';
import { AbonnementService } from '../../services/abonnement.service';

import { RouterModule } from '@angular/router';


@Component({
  selector: 'app-abonnement',
  templateUrl: './abonnement.component.html',
  styleUrls: ['./abonnement.component.css'],
  standalone : true,
  imports: [ RouterModule],
  
 
})
export class AbonnementComponent implements OnInit {
  abonnements: Abonnement[] = [];

  constructor(private abonnementService: AbonnementService) {}

  ngOnInit(): void {
    this.abonnementService.getAll().subscribe(data => {
      this.abonnements = data;
    });
  }
}
