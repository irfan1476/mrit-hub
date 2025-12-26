import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AdminController } from './admin.controller';
import { AdminService } from './admin.service';
import { DepartmentHod } from './entities/department-hod.entity';
import { ApprovalHierarchy } from './entities/approval-hierarchy.entity';
import { Faculty } from '../leave/entities/faculty.entity';
import { Department } from './entities/department.entity';
import { Designation } from './entities/designation.entity';
import { LeaveType } from '../leave/entities/leave-type.entity';
import { AcademicYear } from '../leave/entities/academic-year.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      DepartmentHod,
      ApprovalHierarchy,
      Faculty,
      Department,
      Designation,
      LeaveType,
      AcademicYear,
    ]),
  ],
  controllers: [AdminController],
  providers: [AdminService],
  exports: [AdminService],
})
export class AdminModule {}