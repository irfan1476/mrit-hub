import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum SmsStatus {
  PENDING = 'PENDING',
  SENT = 'SENT',
  DELIVERED = 'DELIVERED',
  FAILED = 'FAILED',
  REJECTED = 'REJECTED',
}

@Entity('sms_log')
export class SmsLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  phone_number: string;

  @Column({ type: 'text' })
  message: string;

  @Column({ type: 'enum', enum: SmsStatus, default: SmsStatus.PENDING })
  status: SmsStatus;

  @Column({ nullable: true })
  template_id: number;

  @Column({ nullable: true })
  student_id: number;

  @Column({ nullable: true })
  session_id: number;

  @Column({ nullable: true })
  gateway_message_id: string;

  @Column({ nullable: true })
  gateway_response: string;

  @Column({ type: 'text', nullable: true })
  error_message: string;

  @Column({ type: 'timestamp', nullable: true })
  sent_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  delivered_at: Date;

  @Column({ default: 0 })
  retry_count: number;

  @Column({ type: 'decimal', precision: 10, scale: 4, nullable: true })
  cost: number;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}