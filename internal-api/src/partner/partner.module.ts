import { Module } from '@nestjs/common';
import { RewardModule } from '../reward/reward.module';
import { PartnerController } from './partner.controller';
import { PartnerService } from './partner.service';

@Module({
  imports: [RewardModule],
  controllers: [PartnerController],
  providers: [PartnerService],
})
export class PartnerModule {}
