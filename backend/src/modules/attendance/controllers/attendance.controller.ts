import { Controller, Post, Get, Body, Query } from '@nestjs/common';
import { AttendanceService } from '../services/attendance.service';
import { CreateAttendanceSessionDto } from '../dto/create-session.dto';
import { MarkAttendanceDto } from '../dto/mark-attendance.dto';
import { AttendanceReportDto } from '../dto/attendance-report.dto';
import { GetStudentsDto } from '../dto/get-students.dto';

@Controller('attendance')
export class AttendanceController {
  constructor(private readonly attendanceService: AttendanceService) {}

  @Post('session')
  async createSession(@Body() dto: CreateAttendanceSessionDto) {
    return this.attendanceService.createSession(dto, '1'); // Mock faculty ID
  }

  @Post('mark')
  async markAttendance(@Body() dto: MarkAttendanceDto) {
    return this.attendanceService.markAttendance(dto, '1'); // Mock faculty ID
  }

  @Get('report')
  async getReport(@Query() dto: AttendanceReportDto) {
    return this.attendanceService.getAttendanceReport(dto);
  }

  @Get('students')
  async getStudents(@Query() dto: GetStudentsDto) {
    return this.attendanceService.getStudentsByClass(dto);
  }

  @Get('time-slots')
  async getTimeSlots() {
    return this.attendanceService.getTimeSlots();
  }
}