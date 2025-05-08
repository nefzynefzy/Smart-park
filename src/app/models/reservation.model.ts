export interface Reservation {
  userId: number;
  parkingPlaceId: number;
  matricule: string;
  startTime: string;
  endTime: string;
  vehicleType: string;
  email: string;
  phone: string;
  paymentMethod: string;
  specialRequest: string;
}

export interface ReservationResponse {
  id: number;
  redirect_url: string;
}