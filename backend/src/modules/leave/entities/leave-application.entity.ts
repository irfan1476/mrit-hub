import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
import { LeaveType } from './leave-type.entity';
import { LeaveApproval } from './leave-approval.entity';

export enum LeaveStatus {
  DRAFT = 'DRAFT',
  PENDING_SUBSTITUTE = 'PENDING_SUBSTITUTE',
  PENDING_HOD = 'PENDING_HOD',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  CANCELLED = 'CANCELLED'
}

@Entity('leave_application')
export class LeaveApplication {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  faculty_id: number;

  @Column()
  leave_type_id: number;

  @Column({ type: 'date' })
  from_date: Date;

  @Column({ type: 'date' })
  to_date: Date;

  @Column({ type: 'decimal', precision: 3, scale: 1 })
  total_days: number;

  @Column({ type: 'text' })
  reason: string;

  @Column({ nullable: true })
  substitute_faculty_id: number;

  @Column({ nullable: true })
  hod_id: number;

  @Column({ type: 'enum', enum: LeaveStatus, default: LeaveStatus.PENDING_SUBSTITUTE })
  status: LeaveStatus;

  @Column({ type: 'timestamp', default: () => 'now()' })
  created_at: Date;

  @Column({ type: 'timestamp', default: () => 'now()' })
  updated_at: Date;

  @Column({ length: 100, nullable: true })
  policy_name: string;

  @Column({ nullable: true })
  policy_year: number;

  @ManyToOne(() => LeaveType, leaveType => leaveType.applications)
  @JoinColumn({ name: 'leave_type_id' })
  leave_type: LeaveType;

  @OneToMany(() => LeaveApproval, approval => approval.leave_application)
  approvals: LeaveApproval[];
}