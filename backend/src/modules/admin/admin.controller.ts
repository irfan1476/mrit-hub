import { Controller, Get, Post, Put, Delete, Body, Param } from '@nestjs/common';
import { AdminService } from './admin.service';

@Controller('admin')
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  // Department HOD Management
  @Get('department-hods')
  async getDepartmentHods() {
    return this.adminService.getDepartmentHods();
  }

  @Post('assign-hod')
  async assignHod(@Body() body: { departmentId: number; facultyId: number }) {
    return this.adminService.assignHod(body.departmentId, body.facultyId);
  }

  // Departments
  @Get('departments')
  async getDepartments() {
    return this.adminService.getDepartments();
  }

  @Post('departments')
  async createDepartment(@Body() data: { code: string; dept_name: string }) {
    return this.adminService.createDepartment(data);
  }

  @Put('departments/:id')
  async updateDepartment(@Param('id') id: number, @Body() data: any) {
    return this.adminService.updateDepartment(id, data);
  }

  @Delete('departments/:id')
  async deleteDepartment(@Param('id') id: number) {
    return this.adminService.deleteDepartment(id);
  }

  // Designations
  @Get('designations')
  async getDesignations() {
    return this.adminService.getDesignations();
  }

  @Post('designations')
  async createDesignation(@Body() data: { des_name: string }) {
    return this.adminService.createDesignation(data);
  }

  @Put('designations/:id')
  async updateDesignation(@Param('id') id: number, @Body() data: any) {
    return this.adminService.updateDesignation(id, data);
  }

  @Delete('designations/:id')
  async deleteDesignation(@Param('id') id: number) {
    return this.adminService.deleteDesignation(id);
  }

  // Faculty
  @Get('faculty')
  async getFaculty() {
    return this.adminService.getFaculty();
  }

  @Post('faculty')
  async createFaculty(@Body() data: any) {
    return this.adminService.createFaculty(data);
  }

  @Put('faculty/:id')
  async updateFaculty(@Param('id') id: number, @Body() data: any) {
    return this.adminService.updateFaculty(id, data);
  }

  @Delete('faculty/:id')
  async deleteFaculty(@Param('id') id: number) {
    return this.adminService.deleteFaculty(id);
  }

  // Leave Types
  @Get('leave-types')
  async getLeaveTypes() {
    return this.adminService.getLeaveTypes();
  }

  @Post('leave-types')
  async createLeaveType(@Body() data: any) {
    return this.adminService.createLeaveType(data);
  }

  @Put('leave-types/:id')
  async updateLeaveType(@Param('id') id: number, @Body() data: any) {
    return this.adminService.updateLeaveType(id, data);
  }

  @Delete('leave-types/:id')
  async deleteLeaveType(@Param('id') id: number) {
    return this.adminService.deleteLeaveType(id);
  }

  // Academic Years
  @Get('academic-years')
  async getAcademicYears() {
    return this.adminService.getAcademicYears();
  }

  @Post('academic-years')
  async createAcademicYear(@Body() data: { yr: string }) {
    return this.adminService.createAcademicYear(data);
  }

  @Put('academic-years/:id')
  async updateAcademicYear(@Param('id') id: number, @Body() data: any) {
    return this.adminService.updateAcademicYear(id, data);
  }

  @Delete('academic-years/:id')
  async deleteAcademicYear(@Param('id') id: number) {
    return this.adminService.deleteAcademicYear(id);
  }
}