import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AttendanceSession } from './entities/attendance-session.entity';
import { AttendanceRecord } from './entities/attendance-record.entity';
import { AttendanceLog } from './entities/attendance-log.entity';
import { AttendanceSummary } from './entities/attendance-summary.entity';
import { TimeSlot } from './entities/time-slot.entity';
import { Timetable } from './entities/timetable.entity';
import { StudentData } from './entities/student-data.entity';
import { SmsTemplate } from '../sms/entities/sms-template.entity';
import { SmsLog } from '../sms/entities/sms-log.entity';
import { AttendanceController } from './controllers/attendance.controller';
import { AttendanceService } from './services/attendance.service';
import { SmsModule } from '../sms/sms.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      AttendanceSession,
      AttendanceRecord,
      AttendanceLog,
      AttendanceSummary,
      TimeSlot,
      Timetable,
      StudentData,
      SmsTemplate,
      SmsLog,
    ]),
    SmsModule,
  ],
  controllers: [AttendanceController],
  providers: [AttendanceService],
  exports: [AttendanceService],
})
export class AttendanceModule {}