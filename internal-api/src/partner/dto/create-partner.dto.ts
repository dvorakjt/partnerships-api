import { IsBoolean, IsOptional } from 'class-validator';

export class CreatePartnerDto {
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
