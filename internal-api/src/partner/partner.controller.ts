import {
  Body,
  Controller,
  Delete,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  Patch,
  Post,
  Put,
} from '@nestjs/common';
import { CreateRewardDto } from '../reward/dto/create-reward.dto';
import { RewardService } from '../reward/reward.service';
import { CreateLocationDto } from './dto/create-location.dto';
import { CreatePartnerDto } from './dto/create-partner.dto';
import { UpdatePartnerDto } from './dto/update-partner.dto';
import { UpsertPartnerTranslationDto } from './dto/upsert-partner-translation.dto';
import { PartnerService } from './partner.service';

@Controller('partners')
export class PartnerController {
  constructor(
    private readonly partnerService: PartnerService,
    private readonly rewardService: RewardService,
  ) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  createPartner(@Body() dto: CreatePartnerDto) {
    return this.partnerService.createPartner(dto);
  }

  @Get(':id')
  getPartner(@Param('id') id: string) {
    return this.partnerService.getPartner(+id);
  }

  @Patch(':id')
  updatePartner(@Param('id') id: string, @Body() dto: UpdatePartnerDto) {
    return this.partnerService.updatePartner(+id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  deletePartner(@Param('id') id: string) {
    return this.partnerService.deletePartner(+id);
  }

  @Put(':id/translations/:lang')
  upsertTranslation(
    @Param('id') id: string,
    @Param('lang') lang: string,
    @Body() dto: UpsertPartnerTranslationDto,
  ) {
    return this.partnerService.upsertTranslation(+id, lang, dto);
  }

  @Delete(':id/translations/:lang')
  @HttpCode(HttpStatus.NO_CONTENT)
  deleteTranslation(@Param('id') id: string, @Param('lang') lang: string) {
    return this.partnerService.deleteTranslation(+id, lang);
  }

  @Get(':id/locations')
  listLocations(@Param('id') id: string) {
    return this.partnerService.listLocations(+id);
  }

  @Post(':id/locations')
  @HttpCode(HttpStatus.CREATED)
  createLocation(@Param('id') id: string, @Body() dto: CreateLocationDto) {
    return this.partnerService.createLocation(+id, dto);
  }

  @Delete(':id/locations/:locationId')
  @HttpCode(HttpStatus.NO_CONTENT)
  deleteLocation(@Param('id') id: string, @Param('locationId') locationId: string) {
    return this.partnerService.deleteLocation(+id, +locationId);
  }

  @Get(':id/rewards')
  listRewards(@Param('id') id: string) {
    return this.rewardService.listRewardsForPartner(+id);
  }

  @Post(':id/rewards')
  @HttpCode(HttpStatus.CREATED)
  createReward(@Param('id') id: string, @Body() dto: CreateRewardDto) {
    return this.rewardService.createReward(+id, dto);
  }
}
