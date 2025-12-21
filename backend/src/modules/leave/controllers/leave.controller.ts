import { Controller, Get, Post, Body, Param, UseGuards, Request, Query } from '@nestjs/common';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { LeaveService } from '../services/leave.service';
import { ApplyLeaveDto } from '../dto/apply-leave.dto';
import { ApproveLeaveDto } from '../dto/approve-leave.dto';
import { ApprovalStage } from '../entities/leave-approval.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Faculty } from '../entities/faculty.entity';

@Controller('leave')
export class LeaveController {
  constructor(
    private leaveService: LeaveService,
    @InjectRepository(Faculty)
    private facultyRepo: Repository<Faculty>
  ) {}

  // Public endpoints for testing
  @Get('types')
  async getLeaveTypes() {
    return await this.leaveService.getLeaveTypes();
  }

  @UseGuards(JwtAuthGuard)
  @Get('faculty-list')
  async getFacultyList() {
    return await this.facultyRepo.find({
      select: ['id', 'faculty_name', 'employee_id'],
      where: { active: true },
      order: { faculty_name: 'ASC' }
    });
  }

  // Protected endpoints
  @UseGuards(JwtAuthGuard)
  @Get('balance')
  async getLeaveBalances(@Request() req, @Query('year') year?: number) {
    return await this.leaveService.getLeaveBalances(req.user.facultyId, year);
  }

  @UseGuards(JwtAuthGuard)
  @Post('apply')
  async applyLeave(@Body() dto: ApplyLeaveDto, @Request() req) {
    return await this.leaveService.applyLeave(dto, req.user.facultyId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('my-applications')
  async getMyApplications(@Request() req) {
    return await this.leaveService.getMyApplications(req.user.facultyId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('pending-approvals/substitute')
  async getPendingSubstituteApprovals(@Request() req) {
    return await this.leaveService.getPendingApprovals(req.user.facultyId, ApprovalStage.SUBSTITUTE);
  }

  @UseGuards(JwtAuthGuard)
  @Get('pending-approvals/hod')
  async getPendingHodApprovals(@Request() req) {
    return await this.leaveService.getPendingApprovals(req.user.facultyId, ApprovalStage.HOD);
  }

  @UseGuards(JwtAuthGuard)
  @Post('approve/:id/substitute')
  async approveAsSubstitute(
    @Param('id') id: number,
    @Body() dto: ApproveLeaveDto,
    @Request() req
  ) {
    return await this.leaveService.approveLeave(id, req.user.facultyId, ApprovalStage.SUBSTITUTE, dto);
  }

  @UseGuards(JwtAuthGuard)
  @Post('approve/:id/hod')
  async approveAsHod(
    @Param('id') id: number,
    @Body() dto: ApproveLeaveDto,
    @Request() req
  ) {
    return await this.leaveService.approveLeave(id, req.user.facultyId, ApprovalStage.HOD, dto);
  }
}