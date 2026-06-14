import { HttpException, HttpStatus, Inject, Injectable } from '@nestjs/common';
import { DB_TOKEN, KyselyDB } from '../database/database.module';
import { CreateLocationDto } from './dto/create-location.dto';
import { CreatePartnerDto } from './dto/create-partner.dto';
import { UpdatePartnerDto } from './dto/update-partner.dto';
import { UpsertPartnerTranslationDto } from './dto/upsert-partner-translation.dto';
import { Partner, PartnerLocation, PartnerTranslation } from './interfaces/partner.interface';

@Injectable()
export class PartnerService {
  constructor(@Inject(DB_TOKEN) private readonly db: KyselyDB) {}

  async createPartner(dto: CreatePartnerDto): Promise<Partner> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }

  async getPartner(id: number): Promise<Partner> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }

  async updatePartner(id: number, dto: UpdatePartnerDto): Promise<Partner> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }

  async deletePartner(id: number): Promise<void> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }

  async upsertTranslation(
    id: number,
    lang: string,
    dto: UpsertPartnerTranslationDto,
  ): Promise<PartnerTranslation> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }

  async deleteTranslation(id: number, lang: string): Promise<void> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }

  async listLocations(id: number): Promise<PartnerLocation[]> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }

  async createLocation(partnerId: number, dto: CreateLocationDto): Promise<PartnerLocation> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }

  async deleteLocation(partnerId: number, locationId: number): Promise<void> {
    throw new HttpException('Not implemented', HttpStatus.NOT_IMPLEMENTED);
  }
}
