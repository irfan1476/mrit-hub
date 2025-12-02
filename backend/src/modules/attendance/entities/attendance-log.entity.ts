import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { AttendanceRecord } from './attendance-record.entity';

@Entity('attendance_log')
export class AttendanceLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  session_id: number;

  @Column({ nullable: true })
  student_id: number;

  @Column({ type: 'varchar', length: 5, nullable: true })
  old_status: string;

  @Column({ type: 'varchar', length: 5, nullable: true })
  new_status: string;

  @Column({ nullable: true })
  changed_by: number;

  @Column({ type: 'timestamp', default: () => 'now()' })
  changed_at: Date;

  @Column({ type: 'text', nullable: true })
  reason: string;

  @Column({ type: 'enum', enum: ['CREATED', 'UPDATED', 'DELETED'], default: 'CREATED' })
  action: string;

  @Column({ type: 'text', nullable: true })
  old_remarks: string;

  @Column({ type: 'text', nullable: true })
  new_remarks: string;

  @Column({ nullable: false })
  changed_by_faculty_id: number;

  @Column({ type: 'inet', nullable: true })
  ip_address: string;

  @Column({ type: 'text', nullable: true })
  user_agent: string;

  @Column({ nullable: true })
  attendance_record_id: number;

  @ManyToOne(() => AttendanceRecord, record => record.logs)
  @JoinColumn({ name: 'attendance_record_id' })
  attendance_record: AttendanceRecord;
}