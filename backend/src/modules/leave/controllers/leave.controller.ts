import { Controller, Get, Post, Body, Param, UseGuards, Request, Query } from '@nestjs/common';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { LeaveService } from '../services/leave.service';
import { ApplyLeaveDto } from '../dto/apply-leave.dto';
import { ApproveLeaveDto } from '../dto/approve-leave.dto';
import { ApprovalStage } from '../entities/leave-approval.entity';

@Controller('leave')
export class LeaveController {
  constructor(private leaveService: LeaveService) {}

  // Public endpoints for testing
  @Get('types')
  async getLeaveTypes() {
    return await this.leaveService.getLeaveTypes();
  }

  @Get('demo/balance')
  async getDemoBalance() {
    // Return demo balance for faculty ID 1
    return await this.leaveService.getLeaveBalances(1, 1);
  }

  @Get('demo/applications')
  async getDemoApplications() {
    // Return demo applications for faculty ID 1
    return await this.leaveService.getMyApplications(1);
  }

  @Post('demo/apply')
  async demoApplyLeave(@Body() dto: ApplyLeaveDto) {
    // Use faculty ID 1 for demo
    return await this.leaveService.applyLeave(dto, 1);
  }

  // Protected endpoints
  @UseGuards(JwtAuthGuard)
  @Get('balance')
  async getLeaveBalances(@Request() req, @Query('year') year?: number) {
    return await this.leaveService.getLeaveBalances(req.user.facultyId, year || 1);
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