import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TimeSlot } from '../attendance/entities/time-slot.entity';
import { LeaveApplication } from '../leave/entities/leave-application.entity';
import { LeaveBalance } from '../leave/entities/leave-balance.entity';

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(TimeSlot)
    private timeSlotRepo: Repository<TimeSlot>,
    @InjectRepository(LeaveApplication)
    private leaveAppRepo: Repository<LeaveApplication>,
    @InjectRepository(LeaveBalance)
    private leaveBalanceRepo: Repository<LeaveBalance>,
  ) {}

  async getFacultyInfo(facultyId: number) {
    try {
      const query = `
        SELECT 
          f.faculty_name,
          f.emp_id,
          d.dept_name,
          f.email_org
        FROM faculty f
        LEFT JOIN department d ON f.dept_id = d.id
        WHERE f.id = $1
      `;
      
      const result = await this.timeSlotRepo.query(query, [facultyId]);
      
      if (result.length > 0) {
        const faculty = result[0];
        return {
          name: faculty.faculty_name,
          department: faculty.dept_name || 'Department',
          designation: 'Faculty',
          employeeCode: faculty.emp_id,
          email: faculty.email_org,
          role: 'FACULTY'
        };
      }
    } catch (error) {
      console.error('Error fetching faculty info:', error);
    }
    
    // Fallback if no data found
    return {
      name: 'Unknown Faculty',
      department: 'Unknown Department',
      designation: 'Faculty',
      employeeCode: 'N/A',
      role: 'FACULTY'
    };
  }

  async getTodaySchedule(facultyId: number, date?: string) {
    const targetDate = date ? new Date(date) : new Date();
    const dayOfWeek = targetDate.getDay(); // 0=Sunday, 1=Monday, etc.
    
    try {
      // Query timetable for faculty's schedule
      const query = `
        SELECT 
          t.day_of_week,
          ts.slot_name,
          ts.start_time,
          ts.end_time,
          c.course_name,
          c.course_code,
          c.semester,
          d.dept_name,
          d.code as dept_code,
          s.name as section_name,
          t.room_number
        FROM timetable t
        JOIN course_offering co ON t.course_offering_id = co.id
        JOIN course c ON co.course_id = c.id
        JOIN time_slot ts ON t.time_slot_id = ts.id
        JOIN department d ON c.branch = d.code
        LEFT JOIN section s ON co.section_id = s.id
        WHERE co.faculty_id = $1 
        AND t.day_of_week = $2 
        AND t.active = true
        AND co.active = true
        ORDER BY ts.start_time
      `;
      
      const schedule = await this.timeSlotRepo.query(query, [facultyId, dayOfWeek]);
      
      if (schedule.length === 0) {
        return [];
      }
      
      const currentTime = new Date();
      const currentHour = currentTime.getHours();
      const currentMinute = currentTime.getMinutes();
      
      return schedule.map(slot => {
        const [slotHour, slotMinute] = slot.start_time.split(':').map(Number);
        const slotTimeMinutes = slotHour * 60 + slotMinute;
        const currentTimeMinutes = currentHour * 60 + currentMinute;
        
        const isCurrent = Math.abs(slotTimeMinutes - currentTimeMinutes) <= 60;
        const isUpcoming = slotTimeMinutes > currentTimeMinutes && slotTimeMinutes - currentTimeMinutes <= 60;
        
        return {
          time: this.formatTime(slot.start_time),
          endTime: this.formatTime(slot.end_time),
          timeSlot: slot.slot_name,
          subject: `${slot.dept_name} - ${slot.section_name || 'ALL'}`,
          course: `${slot.course_name} (${slot.course_code})`,
          room: slot.room_number,
          current: isCurrent,
          upcoming: isUpcoming,
          substitute: null,
          // Add mapping data for attendance
          departmentCode: slot.dept_code,
          semester: slot.semester,
          sectionName: slot.section_name || 'ALL',
          courseCode: slot.course_code
        };
      });
    } catch (error) {
      console.error('Error fetching schedule:', error);
      return [];
    }
  }

  async getLeaveOverview(facultyId: number) {
    try {
      const applications = await this.leaveAppRepo.find({
        where: { faculty_id: facultyId },
        relations: ['leave_type'],
        order: { created_at: 'DESC' }
      });

      const balances = await this.leaveBalanceRepo.find({
        where: { faculty_id: facultyId },
        relations: ['leave_type']
      });

      const stats = {
        pending: applications.filter(app => app.status.includes('PENDING')).length,
        approved: applications.filter(app => app.status === 'APPROVED').length,
        rejected: applications.filter(app => app.status === 'REJECTED').length
      };

      const leaveBalances = balances.map(balance => ({
        type: balance.leave_type.code,
        name: balance.leave_type.name,
        used: parseFloat(balance.opening_balance.toString()) - parseFloat(balance.remaining_days.toString()),
        total: parseFloat(balance.opening_balance.toString()),
        remaining: parseFloat(balance.remaining_days.toString())
      }));

      const recentApplication = applications[0];
      const recent = recentApplication ? {
        type: recentApplication.leave_type?.name || 'Unknown',
        status: recentApplication.status,
        date: recentApplication.created_at.toDateString()
      } : null;

      return { stats, balances: leaveBalances, recent };
    } catch (error) {
      return { stats: { pending: 0, approved: 0, rejected: 0 }, balances: [], recent: null };
    }
  }

  async getApprovals(facultyId: number) {
    // Return empty arrays - approvals should come from leave service
    return { substitute: [], hod: [] };
  }

  async getNotices() {
    // Return empty array - notices should come from database
    return [];
  }

  private formatTime(timeString: string): string {
    const [hours, minutes] = timeString.split(':');
    const hour = parseInt(hours);
    const ampm = hour >= 12 ? 'PM' : 'AM';
    const displayHour = hour > 12 ? hour - 12 : (hour === 0 ? 12 : hour);
    return `${displayHour}:${minutes} ${ampm}`;
  }
}