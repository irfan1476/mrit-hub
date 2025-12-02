import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LeaveType } from '../entities/leave-type.entity';
import { LeaveBalance } from '../entities/leave-balance.entity';
import { LeaveApplication, LeaveStatus } from '../entities/leave-application.entity';
import { LeaveApproval, ApprovalStage, ApprovalDecision } from '../entities/leave-approval.entity';
import { ApplyLeaveDto } from '../dto/apply-leave.dto';
import { ApproveLeaveDto } from '../dto/approve-leave.dto';

@Injectable()
export class LeaveService {
  constructor(
    @InjectRepository(LeaveType)
    private leaveTypeRepo: Repository<LeaveType>,
    @InjectRepository(LeaveBalance)
    private leaveBalanceRepo: Repository<LeaveBalance>,
    @InjectRepository(LeaveApplication)
    private leaveApplicationRepo: Repository<LeaveApplication>,
    @InjectRepository(LeaveApproval)
    private leaveApprovalRepo: Repository<LeaveApproval>,
  ) {}

  async getLeaveTypes() {
    return await this.leaveTypeRepo.find({ where: { active: true } });
  }

  async getLeaveBalances(facultyId: number, academicYearId: number = 1) {
    return await this.leaveBalanceRepo
      .createQueryBuilder('balance')
      .leftJoinAndSelect('balance.leave_type', 'leave_type')
      .where('balance.faculty_id = :facultyId', { facultyId })
      .andWhere('balance.academic_year_id = :academicYearId', { academicYearId })
      .getMany();
  }

  async applyLeave(dto: ApplyLeaveDto, facultyId: number) {
    const leaveType = await this.leaveTypeRepo.findOne({ where: { id: dto.leave_type_id } });
    if (!leaveType || !leaveType.active) {
      throw new NotFoundException('Leave type not found or inactive');
    }

    // Validate dates
    const fromDate = new Date(dto.from_date);
    const toDate = new Date(dto.to_date);
    if (fromDate > toDate) {
      throw new BadRequestException('From date cannot be after to date');
    }

    // Check for overlapping applications
    const overlapping = await this.leaveApplicationRepo
      .createQueryBuilder('app')
      .where('app.faculty_id = :facultyId', { facultyId })
      .andWhere('app.status NOT IN (:...statuses)', { 
        statuses: [LeaveStatus.REJECTED, LeaveStatus.CANCELLED] 
      })
      .andWhere('(app.from_date <= :toDate AND app.to_date >= :fromDate)', {
        fromDate: dto.from_date,
        toDate: dto.to_date
      })
      .getOne();

    if (overlapping) {
      throw new BadRequestException('Overlapping leave application exists');
    }

    // Check balance
    const balance = await this.leaveBalanceRepo.findOne({
      where: { 
        faculty_id: facultyId, 
        leave_type_id: dto.leave_type_id,
        academic_year_id: 1 // Current year
      }
    });

    if (balance && balance.remaining_days < dto.total_days) {
      throw new BadRequestException('Insufficient leave balance');
    }

    // Create application
    const application = this.leaveApplicationRepo.create({
      faculty_id: facultyId,
      leave_type_id: dto.leave_type_id,
      from_date: fromDate,
      to_date: toDate,
      total_days: dto.total_days,
      reason: dto.reason,
      substitute_faculty_id: dto.substitute_faculty_id,
      status: leaveType.requires_substitute ? LeaveStatus.PENDING_SUBSTITUTE : LeaveStatus.PENDING_HOD,
      policy_year: new Date().getFullYear()
    });

    const savedApplication = await this.leaveApplicationRepo.save(application);

    // Create approval records
    if (leaveType.requires_substitute && dto.substitute_faculty_id) {
      await this.leaveApprovalRepo.save({
        leave_application_id: savedApplication.id,
        approver_id: dto.substitute_faculty_id,
        stage: ApprovalStage.SUBSTITUTE
      });
    }

    // Always create HOD approval (will be pending until substitute approves)
    await this.leaveApprovalRepo.save({
      leave_application_id: savedApplication.id,
      approver_id: 1, // Default HOD - should be dynamic
      stage: ApprovalStage.HOD
    });

    return savedApplication;
  }

  async getMyApplications(facultyId: number) {
    return await this.leaveApplicationRepo
      .createQueryBuilder('app')
      .leftJoinAndSelect('app.leave_type', 'leave_type')
      .leftJoinAndSelect('app.approvals', 'approvals')
      .where('app.faculty_id = :facultyId', { facultyId })
      .orderBy('app.created_at', 'DESC')
      .getMany();
  }

  async getPendingApprovals(approverId: number, stage: ApprovalStage) {
    return await this.leaveApprovalRepo
      .createQueryBuilder('approval')
      .leftJoinAndSelect('approval.leave_application', 'app')
      .leftJoinAndSelect('app.leave_type', 'leave_type')
      .where('approval.approver_id = :approverId', { approverId })
      .andWhere('approval.stage = :stage', { stage })
      .andWhere('approval.decision = :decision', { decision: ApprovalDecision.PENDING })
      .andWhere('app.status = :status', { 
        status: stage === ApprovalStage.SUBSTITUTE ? LeaveStatus.PENDING_SUBSTITUTE : LeaveStatus.PENDING_HOD 
      })
      .getMany();
  }

  async approveLeave(applicationId: number, approverId: number, stage: ApprovalStage, dto: ApproveLeaveDto) {
    const approval = await this.leaveApprovalRepo.findOne({
      where: { 
        leave_application_id: applicationId,
        approver_id: approverId,
        stage: stage
      },
      relations: ['leave_application']
    });

    if (!approval) {
      throw new NotFoundException('Approval record not found');
    }

    if (approval.decision !== ApprovalDecision.PENDING) {
      throw new BadRequestException('Already processed');
    }

    // Update approval
    approval.decision = dto.decision;
    approval.comment = dto.comment;
    approval.decided_at = new Date();
    await this.leaveApprovalRepo.save(approval);

    // Update application status
    const application = approval.leave_application;
    
    if (dto.decision === ApprovalDecision.REJECTED) {
      application.status = LeaveStatus.REJECTED;
    } else if (stage === ApprovalStage.SUBSTITUTE) {
      application.status = LeaveStatus.PENDING_HOD;
    } else if (stage === ApprovalStage.HOD) {
      application.status = LeaveStatus.APPROVED;
      
      // Update balance
      await this.updateLeaveBalance(application.faculty_id, application.leave_type_id, application.total_days);
    }

    await this.leaveApplicationRepo.save(application);
    return application;
  }

  private async updateLeaveBalance(facultyId: number, leaveTypeId: number, days: number) {
    const balance = await this.leaveBalanceRepo.findOne({
      where: { 
        faculty_id: facultyId, 
        leave_type_id: leaveTypeId,
        academic_year_id: 1
      }
    });

    if (balance) {
      balance.used_days += days;
      balance.remaining_days -= days;
      await this.leaveBalanceRepo.save(balance);
    }
  }
}