export interface Partner {
  id: number;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface PartnerTranslation {
  partnerId: number;
  languageTag: string;
  name: string;
  description: string;
  logoUrl: string;
  reasonForSupporting8by8: string;
  webAddressText: string;
  webAddressUrl: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface PartnerLocation {
  id: number;
  partnerId: number;
  coordinates: { latitude: number; longitude: number };
  createdAt: Date;
  updatedAt: Date;
}
