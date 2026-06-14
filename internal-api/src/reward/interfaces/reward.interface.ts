import type { VoucherType, RedemptionForum } from '../dto/create-reward.dto';

export interface Reward {
  id: string;
  partnerId: number;
  availableFromExact: Date;
  availableUntilExact: Date;
  redemptionForums: RedemptionForum[];
  voucherType: VoucherType;
  createdAt: Date;
  updatedAt: Date;
}

export interface RewardTranslation {
  rewardId: string;
  languageTag: string;
  shortDescription: string;
  longDescription: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface RewardCategory {
  rewardId: string;
  categoryId: number;
  createdAt: Date;
  updatedAt: Date;
}
