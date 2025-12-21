import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { LeaveType } from '../entities/leave-type.entity';
import { LeaveBalance } from '../entities/leave-balance.entity';
import { LeaveApplication, LeaveStatus } from '../entities/leave-application.entity';
import { LeaveApproval, ApprovalStage, ApprovalDecision } from '../entities/leave-approval.entity';
import { Faculty } from '../entities/faculty.entity';
import { AcademicYear } from '../entities/academic-year.entity';
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
    @InjectRepository(Faculty)
    private facultyRepo: Repository<Faculty>,
    @InjectRepository(AcademicYear)
    private academicYearRepo: Repository<AcademicYear>,
  ) {}

  async getLeaveTypes() {
    return await this.leaveTypeRepo.find({ where: { active: true } });
  }

  async getLeaveBalances(facultyId: number, academicYearId?: number) {
    try {
      // Get current academic year if not provided
      if (!academicYearId) {
        const currentYear = await this.academicYearRepo.findOne({
          order: { yr: 'DESC' }
        });
        academicYearId = currentYear?.id;
      }

      if (!academicYearId) {
        return [];
      }

      return await this.leaveBalanceRepo
        .createQueryBuilder('balance')
        .leftJoinAndSelect('balance.leave_type', 'leave_type')
        .where('balance.faculty_id = :facultyId', { facultyId })
        .andWhere('balance.academic_year_id = :academicYearId', { academicYearId })
        .getMany();
    } catch (error) {
      console.error('Error in getLeaveBalances:', error);
      return [];
    }
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
    const currentYear = await this.academicYearRepo.findOne({
      order: { yr: 'DESC' }
    });
    const academicYearId = currentYear?.id;

    if (academicYearId) {
      const balance = await this.leaveBalanceRepo.findOne({
        where: { 
          faculty_id: facultyId, 
          leave_type_id: dto.leave_type_id,
          academic_year_id: academicYearId
        }
      });

      if (balance && balance.remaining_days < dto.total_days) {
        throw new BadRequestException('Insufficient leave balance');
      }
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
      status: (leaveType.requires_substitute && dto.substitute_faculty_id) ? LeaveStatus.PENDING_SUBSTITUTE : LeaveStatus.PENDING_HOD,
      policy_year: new Date().getFullYear()
    });

    const savedApplication = await this.leaveApplicationRepo.save(application);

    // Create approval records based on workflow
    if (leaveType.requires_substitute && dto.substitute_faculty_id) {
      // Create substitute approval first
      await this.leaveApprovalRepo.save({
        leave_application_id: savedApplication.id,
        approver_id: dto.substitute_faculty_id,
        stage: ApprovalStage.SUBSTITUTE
      });
      
      // Create HOD approval (will be pending until substitute approves)
      const hodFaculty = await this.getHODForDepartment(facultyId);
      if (!hodFaculty) {
        throw new BadRequestException('No HOD found for approval');
      }
      await this.leaveApprovalRepo.save({
        leave_application_id: savedApplication.id,
        approver_id: hodFaculty.id,
        stage: ApprovalStage.HOD
      });
    } else {
      // Direct HOD approval (no substitute required)
      const hodFaculty = await this.getHODForDepartment(facultyId);
      if (!hodFaculty) {
        throw new BadRequestException('No HOD found for approval');
      }
      await this.leaveApprovalRepo.save({
        leave_application_id: savedApplication.id,
        approver_id: hodFaculty.id,
        stage: ApprovalStage.HOD
      });
    }

    return savedApplication;
  }

  async getMyApplications(facultyId: number) {
    const applications = await this.leaveApplicationRepo
      .createQueryBuilder('app')
      .leftJoinAndSelect('app.leave_type', 'leave_type')
      .leftJoinAndSelect('app.approvals', 'approvals')
      .where('app.faculty_id = :facultyId', { facultyId })
      .orderBy('app.created_at', 'DESC')
      .getMany();
      
    // Manually fetch substitute faculty information
    for (const app of applications) {
      if (app.substitute_faculty_id) {
        const substituteFaculty = await this.facultyRepo.findOne({
          where: { id: app.substitute_faculty_id },
          select: ['id', 'faculty_name']
        });
        if (substituteFaculty) {
          (app as any).substitute_faculty = substituteFaculty;
        }
      }
    }
    
    return applications;
  }

  async getPendingApprovals(approverId: number, stage: ApprovalStage) {
    const query = this.leaveApprovalRepo
      .createQueryBuilder('approval')
      .leftJoinAndSelect('approval.leave_application', 'app')
      .leftJoinAndSelect('app.leave_type', 'leave_type')
      .where('approval.approver_id = :approverId', { approverId })
      .andWhere('approval.stage = :stage', { stage })
      .andWhere('approval.decision = :decision', { decision: ApprovalDecision.PENDING })
      .andWhere('app.status = :status', { 
        status: stage === ApprovalStage.SUBSTITUTE ? LeaveStatus.PENDING_SUBSTITUTE : LeaveStatus.PENDING_HOD 
      });

    // For HOD approvals, also check that substitute approval is completed (if substitute was required)
    if (stage === ApprovalStage.HOD) {
      query.andWhere('(app.substitute_faculty_id IS NULL OR EXISTS (SELECT 1 FROM leave_approval sub_approval WHERE sub_approval.leave_application_id = app.id AND sub_approval.stage = :subStage AND sub_approval.decision = :approved))', {
        subStage: ApprovalStage.SUBSTITUTE,
        approved: ApprovalDecision.APPROVED
      });
    }

    const approvals = await query.getMany();
    
    // Manually fetch faculty information for each application
    for (const approval of approvals) {
      if (approval.leave_application?.faculty_id) {
        const faculty = await this.facultyRepo.findOne({
          where: { id: approval.leave_application.faculty_id },
          select: ['id', 'faculty_name']
        });
        if (faculty) {
          (approval.leave_application as any).faculty = faculty;
        }
      }
    }
    
    return approvals;
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
      
      // Only update balance after final HOD approval
      await this.updateLeaveBalance(application.faculty_id, application.leave_type_id, application.total_days);
    }

    await this.leaveApplicationRepo.save(application);
    return application;
  }

  private async updateLeaveBalance(facultyId: number, leaveTypeId: number, days: number) {
    const currentYear = await this.academicYearRepo.findOne({
      order: { yr: 'DESC' }
    });
    const academicYearId = currentYear?.id;

    if (!academicYearId) {
      console.log('No active academic year found for balance update');
      return;
    }

    const balance = await this.leaveBalanceRepo.findOne({
      where: { 
        faculty_id: facultyId, 
        leave_type_id: leaveTypeId,
        academic_year_id: academicYearId
      }
    });

    if (balance) {
      balance.used_days += days;
      balance.remaining_days -= days;
      await this.leaveBalanceRepo.save(balance);
    }
  }

  private async getHODForDepartment(facultyId: number): Promise<Faculty | null> {
    // Get faculty's department
    const faculty = await this.facultyRepo.findOne({ 
      where: { id: facultyId },
      select: ['id', 'dept_id']
    });
    
    if (!faculty?.dept_id) {
      console.log(`Faculty ${facultyId} has no department assigned`);
      return null;
    }

    // Find HOD for the same department (designation_id = 37 for HOD)
    const hod = await this.facultyRepo.findOne({
      where: { 
        dept_id: faculty.dept_id,
        designation_id: 37, // HOD designation
        active: true
      },
      select: ['id', 'faculty_name', 'dept_id']
    });

    if (!hod) {
      console.log(`No HOD found for department ${faculty.dept_id}`);
      // Fallback to any HOD if department HOD not found
      return await this.facultyRepo.findOne({
        where: { designation_id: 37, active: true },
        select: ['id', 'faculty_name', 'dept_id']
      });
    }

    return hod;
  }
}