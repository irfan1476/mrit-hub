import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { LeaveBalance } from './leave-balance.entity';
import { LeaveApplication } from './leave-application.entity';

@Entity('leave_type')
export class LeaveType {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  name: string;

  @Column({ length: 20, unique: true })
  code: string;

  @Column({ default: true })
  allow_half_day: boolean;

  @Column({ default: true })
  requires_substitute: boolean;

  @Column({ type: 'decimal', precision: 5, scale: 1, nullable: true })
  max_days_per_year: number;

  @Column({ default: true })
  is_paid: boolean;

  @Column({ default: true })
  active: boolean;

  @Column({ type: 'timestamp', default: () => 'now()' })
  created_at: Date;

  @Column({ type: 'timestamp', default: () => 'now()' })
  updated_at: Date;

  @OneToMany(() => LeaveBalance, balance => balance.leave_type)
  balances: LeaveBalance[];

  @OneToMany(() => LeaveApplication, application => application.leave_type)
  applications: LeaveApplication[];
}