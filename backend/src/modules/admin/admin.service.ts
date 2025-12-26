import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { DepartmentHod } from './entities/department-hod.entity';
import { ApprovalHierarchy } from './entities/approval-hierarchy.entity';
import { Faculty } from '../leave/entities/faculty.entity';
import { Department } from './entities/department.entity';
import { Designation } from './entities/designation.entity';
import { LeaveType } from '../leave/entities/leave-type.entity';
import { AcademicYear } from '../leave/entities/academic-year.entity';

@Injectable()
export class AdminService {
  constructor(
    @InjectRepository(DepartmentHod)
    private departmentHodRepository: Repository<DepartmentHod>,
    @InjectRepository(ApprovalHierarchy)
    private approvalHierarchyRepository: Repository<ApprovalHierarchy>,
    @InjectRepository(Faculty)
    private facultyRepository: Repository<Faculty>,
    @InjectRepository(Department)
    private departmentRepository: Repository<Department>,
    @InjectRepository(Designation)
    private designationRepository: Repository<Designation>,
    @InjectRepository(LeaveType)
    private leaveTypeRepository: Repository<LeaveType>,
    @InjectRepository(AcademicYear)
    private academicYearRepository: Repository<AcademicYear>,
  ) {}

  // Department HOD Management
  async getDepartmentHods() {
    return this.departmentHodRepository.find({
      relations: ['faculty'],
      where: { is_active: true },
    });
  }

  async assignHod(departmentId: number, facultyId: number) {
    await this.departmentHodRepository.update(
      { department_id: departmentId, is_active: true },
      { is_active: false, to_date: new Date() }
    );
    const newHod = this.departmentHodRepository.create({
      department_id: departmentId,
      faculty_id: facultyId,
      is_active: true,
    });
    return this.departmentHodRepository.save(newHod);
  }

  // Departments CRUD
  async getDepartments() {
    return this.departmentRepository.find();
  }

  async createDepartment(data: any) {
    const dept = this.departmentRepository.create(data);
    return this.departmentRepository.save(dept);
  }

  async updateDepartment(id: number, data: any) {
    await this.departmentRepository.update(id, data);
    return this.departmentRepository.findOne({ where: { id } });
  }

  async deleteDepartment(id: number) {
    return this.departmentRepository.delete(id);
  }

  // Designations CRUD
  async getDesignations() {
    return this.designationRepository.find();
  }

  async createDesignation(data: any) {
    const designation = this.designationRepository.create(data);
    return this.designationRepository.save(designation);
  }

  async updateDesignation(id: number, data: any) {
    await this.designationRepository.update(id, data);
    return this.designationRepository.findOne({ where: { id } });
  }

  async deleteDesignation(id: number) {
    return this.designationRepository.delete(id);
  }

  // Faculty CRUD
  async getFaculty() {
    return this.facultyRepository.find({
      where: { active: true },
      order: { faculty_name: 'ASC' },
    });
  }

  async createFaculty(data: any) {
    const faculty = this.facultyRepository.create(data);
    return this.facultyRepository.save(faculty);
  }

  async updateFaculty(id: number, data: any) {
    await this.facultyRepository.update(id, data);
    return this.facultyRepository.findOne({ where: { id } });
  }

  async deleteFaculty(id: number) {
    await this.facultyRepository.update(id, { active: false });
    return { success: true };
  }

  // Leave Types CRUD
  async getLeaveTypes() {
    return this.leaveTypeRepository.find({
      where: { active: true },
      order: { name: 'ASC' },
    });
  }

  async createLeaveType(data: any) {
    const leaveType = this.leaveTypeRepository.create(data);
    return this.leaveTypeRepository.save(leaveType);
  }

  async updateLeaveType(id: number, data: any) {
    await this.leaveTypeRepository.update(id, data);
    return this.leaveTypeRepository.findOne({ where: { id } });
  }

  async deleteLeaveType(id: number) {
    await this.leaveTypeRepository.update(id, { active: false });
    return { success: true };
  }

  // Academic Years CRUD
  async getAcademicYears() {
    return this.academicYearRepository.find({
      order: { yr: 'DESC' },
    });
  }

  async createAcademicYear(data: any) {
    const year = this.academicYearRepository.create(data);
    return this.academicYearRepository.save(year);
  }

  async updateAcademicYear(id: number, data: any) {
    await this.academicYearRepository.update(id, data);
    return this.academicYearRepository.findOne({ where: { id } });
  }

  async deleteAcademicYear(id: number) {
    return this.academicYearRepository.delete(id);
  }
}