import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { AttendanceSession } from '../entities/attendance-session.entity';
import { AttendanceRecord, AttendanceStatus } from '../entities/attendance-record.entity';
import { AttendanceLog } from '../entities/attendance-log.entity';
import { TimeSlot } from '../entities/time-slot.entity';
import { StudentData } from '../entities/student-data.entity';
import { CreateAttendanceSessionDto } from '../dto/create-session.dto';
import { MarkAttendanceDto, AttendanceStatusDto } from '../dto/mark-attendance.dto';
import { AttendanceReportDto } from '../dto/attendance-report.dto';
import { GetStudentsDto } from '../dto/get-students.dto';
import { SmsService } from '../../sms/services/sms.service';

@Injectable()
export class AttendanceService {
  constructor(
    @InjectRepository(AttendanceSession)
    private sessionRepo: Repository<AttendanceSession>,
    @InjectRepository(AttendanceRecord)
    private recordRepo: Repository<AttendanceRecord>,
    @InjectRepository(AttendanceLog)
    private logRepo: Repository<AttendanceLog>,
    @InjectRepository(TimeSlot)
    private timeSlotRepo: Repository<TimeSlot>,
    @InjectRepository(StudentData)
    private studentRepo: Repository<StudentData>,
    private smsService: SmsService,
  ) {}

  async createSession(dto: CreateAttendanceSessionDto, faculty_id: number | string) {
    // Find time slot by name
    const timeSlot = await this.timeSlotRepo.findOne({
      where: { slot_name: dto.time_slot, active: true }
    });

    if (!timeSlot) {
      throw new NotFoundException('Time slot not found');
    }

    // Get department and section mappings from database
    const departmentQuery = `SELECT id, code FROM department WHERE code = $1`;
    const sectionQuery = `SELECT id, name FROM section WHERE name = $1`;
    
    const [deptResult] = await this.timeSlotRepo.query(departmentQuery, [dto.department]);
    const [sectionResult] = await this.timeSlotRepo.query(sectionQuery, [dto.section]);
    
    if (!deptResult || !sectionResult) {
      throw new NotFoundException('Department or section not found');
    }

    const sessionData = {
      faculty_id: typeof faculty_id === 'string' ? parseInt(faculty_id) : faculty_id,
      session_date: new Date(dto.session_date),
      topic: dto.topic,
      created_by: typeof faculty_id === 'string' ? parseInt(faculty_id) : faculty_id,
      time_slot_id: timeSlot.id,
      duration_hours: timeSlot.duration_hours,
      class_type: timeSlot.slot_type,
      department_id: deptResult.id,
      semester_id: parseInt(dto.semester),
      section_id: sectionResult.id,
      subject_code: dto.subject_code,
      edit_deadline: new Date(Date.now() + 36 * 60 * 60 * 1000), // 36 hours from now
    };
    
    const session = this.sessionRepo.create(sessionData);
    
    return await this.sessionRepo.save(session);
  }

  async markAttendance(dto: MarkAttendanceDto, faculty_id: number | string) {
    const session = await this.sessionRepo.findOne({
      where: { id: parseInt(dto.session_id) },
    });

    if (!session) {
      throw new NotFoundException('Session not found');
    }

    // Check 36-hour edit window
    const now = new Date();
    const sessionTime = new Date(session.session_date);
    const hoursDiff = (now.getTime() - sessionTime.getTime()) / (1000 * 60 * 60);
    
    if (hoursDiff > 36) {
      throw new BadRequestException('Attendance edit window (36 hours) has expired');
    }

    const records = [];
    for (const record of dto.attendance_records) {
      // Find student by roll number to get proper student_id
      const student = await this.studentRepo.findOne({
        where: { usn: record.student_id }
      });
      
      if (!student) {
        console.warn(`Student not found: ${record.student_id}`);
        continue;
      }
      
      const attendanceRecordData = {
        session_id: parseInt(dto.session_id),
        student_id: student.id,
        status: record.status === AttendanceStatusDto.PRESENT ? 'P' : 'A',
        marked_by: typeof faculty_id === 'string' ? parseInt(faculty_id) : faculty_id,
      };
      
      const attendanceRecord = this.recordRepo.create(attendanceRecordData);
      records.push(await this.recordRepo.save(attendanceRecord));

      // Skip logging for now to avoid complexity
      // await this.logRepo.save({...});

      // Send SMS for absent students
      if (record.status === AttendanceStatusDto.ABSENT) {
        // Get student phone from database
        const phoneQuery = `SELECT phone FROM student_data WHERE usn = $1`;
        const [phoneResult] = await this.studentRepo.query(phoneQuery, [record.student_id]);
        const parentPhone = phoneResult?.phone || null;
        const studentName = `Student ${record.student_id}`;
        const subject = session.topic || 'Unknown Subject';
        const sessionDate = new Date(session.session_date).toDateString();
        
        if (parentPhone) {
          this.smsService.sendAbsentNotification(studentName, parentPhone, subject, sessionDate)
            .catch(error => console.error('SMS failed:', error));
        }
      }
    }

    return records;
  }

  async getAttendanceReport(dto: AttendanceReportDto) {
    const query = this.recordRepo.createQueryBuilder('record')
      .leftJoinAndSelect('record.session', 'session');

    if (dto.department) {
      query.andWhere('session.department_id = :department', { department: dto.department });
    }
    if (dto.semester) {
      query.andWhere('session.semester_id = :semester', { semester: dto.semester });
    }
    if (dto.section) {
      query.andWhere('session.section_id = :section', { section: dto.section });
    }
    if (dto.subject_code) {
      query.andWhere('session.subject_code = :subject_code', { subject_code: dto.subject_code });
    }
    if (dto.from_date && dto.to_date) {
      query.andWhere('session.session_date BETWEEN :from_date AND :to_date', {
        from_date: dto.from_date,
        to_date: dto.to_date,
      });
    }

    const records = await query.getMany();

    // Calculate attendance percentages
    const studentStats = {};
    records.forEach(record => {
      const key = record.student_id;
      if (!studentStats[key]) {
        studentStats[key] = {
          student_id: record.student_id,
          total_sessions: 0,
          present_count: 0,
          absent_count: 0,
        };
      }
      studentStats[key].total_sessions++;
      if (record.status === AttendanceStatus.PRESENT) {
        studentStats[key].present_count++;
      } else {
        studentStats[key].absent_count++;
      }
    });

    // Add percentage calculation
    Object.values(studentStats).forEach((stat: any) => {
      stat.attendance_percentage = stat.total_sessions > 0 
        ? ((stat.present_count / stat.total_sessions) * 100).toFixed(2)
        : '0.00';
    });

    return Object.values(studentStats);
  }

  async getStudentsByClass(dto: GetStudentsDto) {
    // Get department and section IDs from database
    const departmentQuery = `SELECT id FROM department WHERE code = $1`;
    const sectionQuery = `SELECT id FROM section WHERE name = $1`;
    
    const [deptResult] = await this.studentRepo.query(departmentQuery, [dto.department]);
    const [sectionResult] = await this.studentRepo.query(sectionQuery, [dto.section]);
    
    if (!deptResult || !sectionResult) {
      throw new NotFoundException('Department or section not found');
    }

    const students = await this.studentRepo
      .createQueryBuilder('sd')
      .innerJoin('student_variables', 'sv', 'sd.usn = sv.usn')
      .where('sd.branch_id = :departmentId', { departmentId: deptResult.id })
      .andWhere('sv.semester_id = :semesterId', { semesterId: dto.semester })
      .andWhere('sv.section_id = :sectionId', { sectionId: sectionResult.id })
      .andWhere('sv.active = true')
      .select([
        'sd.id as id',
        'sd.usn as roll_no',
        'sd.student_name as name',
        'sd.usn as admission_no'
      ])
      .getRawMany();

    return students;
  }

  async getTimeSlots() {
    return await this.timeSlotRepo.find({
      where: { active: true },
      order: { start_time: 'ASC' }
    });
  }

  async getSubjects(departmentId: number, semesterId: number) {
    try {
      const query = `
        SELECT c.id, c.course_code, c.course_name, c.credits 
        FROM course c
        WHERE c.branch = (SELECT code FROM department WHERE id = $1) 
        AND c.semester = $2
        ORDER BY c.course_name
      `;
      
      const result = await this.sessionRepo.query(query, [departmentId, semesterId]);
      return result;
    } catch (error) {
      console.error('Error in getSubjects:', error);
      return [];
    }
  }
}