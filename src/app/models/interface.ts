export interface Subscription {
    id: number;
    subscriptionType: string;
    startDate: string;
    endDate: string;
    status: string;
    price: number;
    billingCycle: string;
    parkingDurationLimit: number | null;
    advanceReservationDays: number;
    hasPremiumSpots: boolean;
    hasValetService: boolean;
    supportLevel: string;
    remainingPlaces: number;
    paymentStatus: string;
    sessionId: string;
    autoRenewal: boolean;
    user: { id: number };
  }
  
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