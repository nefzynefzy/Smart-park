import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { NavbarComponent } from "../../navbar/navbar.component";

@Component({
  selector: 'app-abonnement-form',
  templateUrl: './abonnement-form.component.html',
  standalone: true,
  imports: [FormsModule, NavbarComponent],
})
export class AbonnementFormComponent implements OnInit {
  typeAbonnement: string = '';

  // ✅ Déclare les données du formulaire
  formData = {
    type: '',
    nom: '',
    email: '',
    vehicule: '',
    carte: '',
    dateExp: '',
    cvv: ''
  };

  constructor(private route: ActivatedRoute) {}

  ngOnInit(): void {
    // Récupère le type d’abonnement depuis l’URL
    this.typeAbonnement = this.route.snapshot.paramMap.get('type') || '';
    this.formData.type = this.typeAbonnement; // initialise le type dans les données du formulaire
  }

  // ✅ Fonction de soumission du formulaire
  onSubmit() {
    console.log('Formulaire soumis :', this.formData);
    alert('Abonnement effectué avec succès !');
    // Tu peux ici envoyer les données au backend via un service
  }
}
