export interface Reservation {
  id?: number;
  userId: number;
  placeId: number;
  date: string;         // Format: 'YYYY-MM-DD'
  heureDebut: string;   // Format: 'HH:mm'
  heureFin: string;     // Format: 'HH:mm'
  montant: number;
  status?: 'pending' | 'confirmed' | 'canceled'; // Ajout d'un statut
}