// src/app/services/pdf.service.ts
import { Injectable } from '@angular/core';
import { jsPDF } from 'jspdf';
import { Reservation } from '../models/reservation.model';

@Injectable({
  providedIn: 'root'
})
export class PdfService {
  generatePdf(reservation: Reservation) {
    const doc = new jsPDF();

    doc.setFont('helvetica', 'normal');
    doc.setFontSize(12);

    doc.text('Ticket de Réservation', 20, 20);
    doc.text('====================', 20, 25);

    doc.text(`ID Utilisateur: ${reservation.userId}`, 20, 35);
    doc.text(`ID Place: ${reservation.placeId}`, 20, 40);
    doc.text(`Date: ${reservation.date}`, 20, 45);
    doc.text(`Heure de Début: ${reservation.heureDebut}`, 20, 50);
    doc.text(`Heure de Fin: ${reservation.heureFin}`, 20, 55);
    doc.text(`Montant: ${reservation.montant} TND`, 20, 60);

    doc.text('====================', 20, 70);
    doc.text('Merci pour votre réservation !', 20, 75);

    doc.save('ticket_reservation.pdf');
  }
}
