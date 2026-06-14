import { IsNotEmpty, IsString } from 'class-validator';

export class UpsertRewardTranslationDto {
  @IsString()
  @IsNotEmpty()
  shortDescription: string;

  @IsString()
  @IsNotEmpty()
  longDescription: string;
}
