import { Module } from '@nestjs/common';
import { DatabaseModule } from './database/database.module';
import { PartnerModule } from './partner/partner.module';
import { RewardModule } from './reward/reward.module';

@Module({
  imports: [DatabaseModule, PartnerModule, RewardModule],
})
export class AppModule {}
