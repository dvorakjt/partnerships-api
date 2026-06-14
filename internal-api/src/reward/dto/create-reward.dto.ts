import { IsArray, IsDateString, IsEnum, ArrayNotEmpty } from 'class-validator';

export const VOUCHER_TYPES = ['MULTIPLE_USE', 'SINGLE_USE', 'ON_DEMAND', 'MANUAL'] as const;
export const REDEMPTION_FORUMS = ['ONLINE', 'IN_STORE'] as const;

export type VoucherType = (typeof VOUCHER_TYPES)[number];
export type RedemptionForum = (typeof REDEMPTION_FORUMS)[number];

export class CreateRewardDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsEnum(REDEMPTION_FORUMS, { each: true })
  redemptionForums: RedemptionForum[];

  @IsEnum(VOUCHER_TYPES)
  voucherType: VoucherType;

  @IsDateString()
  availableFromExact: string;

  @IsDateString()
  availableUntilExact: string;
}
