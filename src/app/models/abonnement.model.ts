export interface SubscriptionPlan {
    id: string;
    name: string;
    monthlyPrice: number;
    features: string[];
    excludedFeatures: string[];
    isPopular: boolean;
}

export type BillingType = 'monthly' | 'annual';

export type PaymentMethod = 'card' | 'paypal' | 'apple' | 'google';

export interface PersonalInfo {
    firstName: string;
    lastName: string;
    email: string;
    phone: string;
    carModel: string;
    licensePlate: string;
}

export interface AdditionalOptions {
    damageProtection: boolean;
    chargingStations: boolean;
    cleaningService: boolean;
}

export interface CardDetails {
    name: string;
    number: string;
    expiry: string;
    cvv: string;
}

export interface Abonnement {
    plan: string;
    billingType: BillingType;
    personalInfo: PersonalInfo;
    options: AdditionalOptions;
    paymentMethod: PaymentMethod;
    cardDetails: CardDetails;
    saveCard: boolean;
}
