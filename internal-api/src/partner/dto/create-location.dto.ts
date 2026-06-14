import { IsNumber, IsLatitude, IsLongitude, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class CoordinatesDto {
  @IsLatitude()
  latitude: number;

  @IsLongitude()
  longitude: number;
}

export class CreateLocationDto {
  @ValidateNested()
  @Type(() => CoordinatesDto)
  coordinates: CoordinatesDto;
}
