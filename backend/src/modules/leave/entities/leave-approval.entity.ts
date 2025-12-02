import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { LeaveApplication } from './leave-application.entity';

export enum ApprovalStage {
  SUBSTITUTE = 'SUBSTITUTE',
  HOD = 'HOD'
}

export enum ApprovalDecision {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED'
}

@Entity('leave_approval')
export class LeaveApproval {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  leave_application_id: number;

  @Column()
  approver_id: number;

  @Column({ type: 'enum', enum: ApprovalStage })
  stage: ApprovalStage;

  @Column({ type: 'enum', enum: ApprovalDecision, default: ApprovalDecision.PENDING })
  decision: ApprovalDecision;

  @Column({ type: 'text', nullable: true })
  comment: string;

  @Column({ type: 'timestamp', nullable: true })
  decided_at: Date;

  @Column({ type: 'timestamp', default: () => 'now()' })
  created_at: Date;

  @ManyToOne(() => LeaveApplication, application => application.approvals)
  @JoinColumn({ name: 'leave_application_id' })
  leave_application: LeaveApplication;
}