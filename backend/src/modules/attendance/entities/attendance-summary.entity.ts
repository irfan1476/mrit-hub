import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';

@Entity('attendance_summary')
@Index(['student_id', 'course_id', 'academic_year_id'])
export class AttendanceSummary {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  student_id: number;

  @Column()
  course_id: number;

  @Column()
  faculty_id: number;

  @Column()
  department_id: number;

  @Column()
  semester: number;

  @Column()
  section_id: number;

  @Column()
  academic_year_id: number;

  @Column({ default: 0 })
  total_sessions: number;

  @Column({ default: 0 })
  present_count: number;

  @Column({ default: 0 })
  absent_count: number;

  @Column({ default: 0 })
  late_count: number;

  @Column({ default: 0 })
  excused_count: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 0 })
  attendance_percentage: number;

  @Column({ type: 'date', nullable: true })
  last_attendance_date: Date;

  @Column({ default: false })
  is_defaulter: boolean;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 75.0 })
  required_percentage: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}