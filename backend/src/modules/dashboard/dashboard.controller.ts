import { Controller, Get, UseGuards, Request, Query } from '@nestjs/common';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { DashboardService } from './dashboard.service';

@Controller('dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  // Public endpoints for demo
  @Get('faculty-info')
  async getFacultyInfo() {
    return this.dashboardService.getFacultyInfo(1);
  }

  @Get('today-schedule')
  async getTodaySchedule(@Query('date') date?: string) {
    return this.dashboardService.getTodaySchedule(1, date);
  }

  @Get('leave-overview')
  async getLeaveOverview() {
    return this.dashboardService.getLeaveOverview(1);
  }

  @Get('approvals')
  async getApprovals() {
    return this.dashboardService.getApprovals(1);
  }

  // Protected endpoints
  @UseGuards(JwtAuthGuard)
  @Get('protected/faculty-info')
  async getProtectedFacultyInfo(@Request() req) {
    return this.dashboardService.getFacultyInfo(req.user.facultyId);
  }

  @UseGuards(JwtAuthGuard)
  @Get('protected/today-schedule')
  async getProtectedTodaySchedule(@Request() req, @Query('date') date?: string) {
    return this.dashboardService.getTodaySchedule(req.user.facultyId, date);
  }
}