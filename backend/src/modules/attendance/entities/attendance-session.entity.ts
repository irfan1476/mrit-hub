import { Entity, PrimaryGeneratedColumn, Column, OneToMany, ManyToOne, JoinColumn } from 'typeorm';
import { AttendanceRecord } from './attendance-record.entity';
import { TimeSlot } from './time-slot.entity';

@Entity('attendance_session')
export class AttendanceSession {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  course_offering_id: number;

  @Column({ type: 'date' })
  session_date: Date;

  @Column({ nullable: true })
  period: number;

  @Column({ nullable: true })
  created_by: number;

  @Column({ type: 'timestamp', default: () => 'now()' })
  created_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  locked_at: Date;

  @Column({ type: 'varchar', length: 20, default: 'open' })
  status: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  topic: string;

  @Column({ type: 'text', nullable: true })
  notes: string;

  @Column({ default: 0 })
  total_students: number;

  @Column({ default: 0 })
  present_count: number;

  @Column({ default: 0 })
  absent_count: number;

  @Column({ default: false })
  sms_sent: boolean;

  @Column({ type: 'timestamp', nullable: true })
  completed_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  edit_deadline: Date;

  @Column({ nullable: true })
  faculty_id: number;

  @Column({ nullable: true })
  course_id: number;

  // New timetable-related fields
  @Column({ nullable: true })
  time_slot_id: number;

  @Column({ default: 1 })
  duration_hours: number;

  @Column({ length: 20, default: 'THEORY' })
  class_type: string;

  @Column({ length: 20, nullable: true })
  room_number: string;

  @Column({ nullable: true })
  department_id: number;

  @Column({ nullable: true })
  semester_id: number;

  @Column({ nullable: true })
  section_id: number;

  @Column({ length: 10, nullable: true })
  subject_code: string;

  @OneToMany(() => AttendanceRecord, record => record.session)
  attendance_records: AttendanceRecord[];

  @ManyToOne(() => TimeSlot)
  @JoinColumn({ name: 'time_slot_id' })
  time_slot: TimeSlot;
}