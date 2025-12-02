import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, OneToMany } from 'typeorm';
import { AttendanceSession } from './attendance-session.entity';
import { AttendanceLog } from './attendance-log.entity';

export enum AttendanceStatus {
  PRESENT = 'P',
  ABSENT = 'A',
  LATE = 'L',
  EXCUSED = 'OD',
  MEDICAL = 'M',
}

@Entity('attendance_record')
export class AttendanceRecord {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  session_id: number;

  @Column({ nullable: true })
  student_id: number;

  @Column({ type: 'varchar', length: 5, default: 'P' })
  status: string;

  @Column({ nullable: true })
  marked_by: number;

  @Column({ type: 'timestamp', default: () => 'now()' })
  marked_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  updated_at: Date;

  @Column({ type: 'time', nullable: true })
  marked_at_time: string;

  @Column({ nullable: true })
  marked_by_faculty_id: number;

  @Column({ type: 'text', nullable: true })
  remarks: string;

  @Column({ default: false })
  is_edited: boolean;

  @Column({ type: 'timestamp', nullable: true })
  last_edited_at: Date;

  @Column({ nullable: true })
  last_edited_by: number;

  @ManyToOne(() => AttendanceSession, session => session.attendance_records)
  @JoinColumn({ name: 'session_id' })
  session: AttendanceSession;

  @OneToMany(() => AttendanceLog, log => log.attendance_record)
  logs: AttendanceLog[];
}