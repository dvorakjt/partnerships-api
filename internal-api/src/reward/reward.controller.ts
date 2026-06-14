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
import { UpdateRewardDto } from './dto/update-reward.dto';
import { UpsertRewardTranslationDto } from './dto/upsert-reward-translation.dto';
import { RewardService } from './reward.service';

@Controller('rewards')
export class RewardController {
  constructor(private readonly rewardService: RewardService) {}

  @Get(':id')
  getReward(@Param('id') id: string) {
    return this.rewardService.getReward(id);
  }

  @Patch(':id')
  updateReward(@Param('id') id: string, @Body() dto: UpdateRewardDto) {
    return this.rewardService.updateReward(id, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  deleteReward(@Param('id') id: string) {
    return this.rewardService.deleteReward(id);
  }

  @Put(':id/translations/:lang')
  upsertTranslation(
    @Param('id') id: string,
    @Param('lang') lang: string,
    @Body() dto: UpsertRewardTranslationDto,
  ) {
    return this.rewardService.upsertTranslation(id, lang, dto);
  }

  @Delete(':id/translations/:lang')
  @HttpCode(HttpStatus.NO_CONTENT)
  deleteTranslation(@Param('id') id: string, @Param('lang') lang: string) {
    return this.rewardService.deleteTranslation(id, lang);
  }

  @Post(':id/categories')
  @HttpCode(HttpStatus.CREATED)
  addCategory(@Param('id') id: string, @Body('categoryId') categoryId: number) {
    return this.rewardService.addCategory(id, categoryId);
  }

  @Delete(':id/categories/:catId')
  @HttpCode(HttpStatus.NO_CONTENT)
  removeCategory(@Param('id') id: string, @Param('catId') catId: string) {
    return this.rewardService.removeCategory(id, +catId);
  }

  // TODO: voucher sub-resources — shape depends on voucherType:
  //   SINGLE_USE   → GET/POST /rewards/:id/vouchers   (collection)
  //   MULTIPLE_USE → GET/PUT  /rewards/:id/voucher    (singleton)
  //   ON_DEMAND    → GET/PUT  /rewards/:id/voucher-stub
  //   MANUAL       → GET/PUT  /rewards/:id/voucher-stub  (+ translations)
}
