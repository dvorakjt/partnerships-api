import { IsNotEmpty, IsString, IsUrl } from 'class-validator';

export class UpsertPartnerTranslationDto {
  @IsString()
  @IsNotEmpty()
  name: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsUrl()
  logoUrl: string;

  @IsString()
  @IsNotEmpty()
  reasonForSupporting8by8: string;

  @IsString()
  @IsNotEmpty()
  webAddressText: string;

  @IsUrl()
  webAddressUrl: string;
}
