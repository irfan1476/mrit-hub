import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { LeaveType } from './leave-type.entity';

@Entity('leave_balance')
export class LeaveBalance {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  faculty_id: number;

  @Column()
  leave_type_id: number;

  @Column()
  academic_year_id: number;

  @Column({ type: 'decimal', precision: 5, scale: 1, default: 0 })
  opening_balance: number;

  @Column({ type: 'decimal', precision: 5, scale: 1, default: 0 })
  used_days: number;

  @Column({ type: 'decimal', precision: 5, scale: 1, default: 0 })
  remaining_days: number;

  @Column({ type: 'timestamp', default: () => 'now()' })
  last_updated: Date;

  @ManyToOne(() => LeaveType, leaveType => leaveType.balances)
  @JoinColumn({ name: 'leave_type_id' })
  leave_type: LeaveType;
}