import { Controller, Get, Post, Body, Param, UseGuards, Request, Query } from '@nestjs/common';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { LeaveService } from '../services/leave.service';
import { ApplyLeaveDto } from '../dto/apply-leave.dto';
import { ApproveLeaveDto } from '../dto/approve-leave.dto';
import { ApprovalStage } from '../entities/leave-approval.entity';

@Controller('leave')
@UseGuards(JwtAuthGuard)
export class LeaveController {
  constructor(private leaveService: LeaveService) {}

  @Get('types')
  async getLeaveTypes() {
    return await this.leaveService.getLeaveTypes();
  }

  @Get('balance')
  async getLeaveBalances(@Request() req, @Query('year') year?: number) {
    return await this.leaveService.getLeaveBalances(req.user.facultyId, year || 1);
  }

  @Post('apply')
  async applyLeave(@Body() dto: ApplyLeaveDto, @Request() req) {
    return await this.leaveService.applyLeave(dto, req.user.facultyId);
  }

  @Get('my-applications')
  async getMyApplications(@Request() req) {
    return await this.leaveService.getMyApplications(req.user.facultyId);
  }

  @Get('pending-approvals/substitute')
  async getPendingSubstituteApprovals(@Request() req) {
    return await this.leaveService.getPendingApprovals(req.user.facultyId, ApprovalStage.SUBSTITUTE);
  }

  @Get('pending-approvals/hod')
  async getPendingHodApprovals(@Request() req) {
    return await this.leaveService.getPendingApprovals(req.user.facultyId, ApprovalStage.HOD);
  }

  @Post('approve/:id/substitute')
  async approveAsSubstitute(
    @Param('id') id: number,
    @Body() dto: ApproveLeaveDto,
    @Request() req
  ) {
    return await this.leaveService.approveLeave(id, req.user.facultyId, ApprovalStage.SUBSTITUTE, dto);
  }

  @Post('approve/:id/hod')
  async approveAsHod(
    @Param('id') id: number,
    @Body() dto: ApproveLeaveDto,
    @Request() req
  ) {
    return await this.leaveService.approveLeave(id, req.user.facultyId, ApprovalStage.HOD, dto);
  }
}