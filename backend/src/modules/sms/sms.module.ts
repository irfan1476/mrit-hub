import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SmsTemplate } from './entities/sms-template.entity';
import { SmsLog } from './entities/sms-log.entity';
import { SmsService } from './services/sms.service';

@Module({
  imports: [
    TypeOrmModule.forFeature([SmsTemplate, SmsLog]),
  ],
  providers: [SmsService],
  exports: [SmsService],
})
export class SmsModule {}