// src/app/models/reservation.model.ts
export interface Reservation {
    id?: number;
    userId: number;
    placeId: number;
    date: string;
    heureDebut: string;
    heureFin: string;
    montant: number;
  }
  