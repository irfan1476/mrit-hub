import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum TemplateType {
  ABSENCE_ALERT = 'ABSENCE_ALERT',
  DEFAULTER_WARNING = 'DEFAULTER_WARNING',
  ATTENDANCE_SUMMARY = 'ATTENDANCE_SUMMARY',
  GENERAL_NOTIFICATION = 'GENERAL_NOTIFICATION',
}

@Entity('sms_template')
export class SmsTemplate {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  template_name: string;

  @Column({ type: 'enum', enum: TemplateType })
  template_type: TemplateType;

  @Column({ type: 'text' })
  message_template: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'json', nullable: true })
  variables: string[];

  @Column({ default: true })
  is_active: boolean;

  @Column({ nullable: true })
  dlt_template_id: string;

  @Column({ nullable: true })
  sender_id: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}