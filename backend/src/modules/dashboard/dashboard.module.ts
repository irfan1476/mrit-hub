import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DashboardController } from './dashboard.controller';
import { DashboardService } from './dashboard.service';

import { TimeSlot } from '../attendance/entities/time-slot.entity';
import { LeaveApplication } from '../leave/entities/leave-application.entity';
import { LeaveBalance } from '../leave/entities/leave-balance.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      TimeSlot,
      LeaveApplication,
      LeaveBalance,
    ]),
  ],
  controllers: [DashboardController],
  providers: [DashboardService],
  exports: [DashboardService],
})
export class DashboardModule {}