import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { LeaveController } from './controllers/leave.controller';
import { LeaveService } from './services/leave.service';
import { LeaveType } from './entities/leave-type.entity';
import { LeaveBalance } from './entities/leave-balance.entity';
import { LeaveApplication } from './entities/leave-application.entity';
import { LeaveApproval } from './entities/leave-approval.entity';
import { Faculty } from './entities/faculty.entity';
import { AcademicYear } from './entities/academic-year.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      LeaveType,
      LeaveBalance,
      LeaveApplication,
      LeaveApproval,
      Faculty,
      AcademicYear,
    ]),
  ],
  controllers: [LeaveController],
  providers: [LeaveService],
  exports: [LeaveService],
})
export class LeaveModule {}