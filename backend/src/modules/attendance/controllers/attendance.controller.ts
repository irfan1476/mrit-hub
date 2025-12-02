import { Controller, Post, Get, Body, Query, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { AttendanceService } from '../services/attendance.service';
import { CreateAttendanceSessionDto } from '../dto/create-session.dto';
import { MarkAttendanceDto } from '../dto/mark-attendance.dto';
import { AttendanceReportDto } from '../dto/attendance-report.dto';
import { GetStudentsDto } from '../dto/get-students.dto';

@Controller('attendance')
export class AttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  // Public endpoints for testing
  @Get('time-slots')
  async getTimeSlots() {
    return this.attendanceService.getTimeSlots();
  }

  @Get('students')
  async getStudents(@Query() dto: GetStudentsDto) {
    return this.attendanceService.getStudentsByClass(dto);
  }

  @Get('report')
  async getReport(@Query() dto: AttendanceReportDto) {
    return this.attendanceService.getAttendanceReport(dto);
  }

  // Demo endpoints
  @Post('demo/session')
  async demoCreateSession(@Body() dto: CreateAttendanceSessionDto) {
    return this.attendanceService.createSession(dto, 1); // Use faculty ID 1 for demo
  }

  @Post('demo/mark')
  async demoMarkAttendance(@Body() dto: MarkAttendanceDto) {
    return this.attendanceService.markAttendance(dto, 1); // Use faculty ID 1 for demo
  }

  // Protected endpoints
  @UseGuards(JwtAuthGuard)
  @Post('session')
  async createSession(@Body() dto: CreateAttendanceSessionDto, @Request() req) {
    return this.attendanceService.createSession(dto, req.user.facultyId);
  }

  @UseGuards(JwtAuthGuard)
  @Post('mark')
  async markAttendance(@Body() dto: MarkAttendanceDto, @Request() req) {
    return this.attendanceService.markAttendance(dto, req.user.facultyId);
  }


}