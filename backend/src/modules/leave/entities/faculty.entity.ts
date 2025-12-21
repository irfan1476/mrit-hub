import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';

@Entity('faculty')
export class Faculty {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 10, unique: true, nullable: true })
  employee_id: string;

  @Column({ length: 50 })
  faculty_name: string;

  @Column({ length: 12, nullable: true })
  phone: string;

  @Column({ length: 5, nullable: true })
  short_name: string;

  @Column({ length: 50, nullable: true })
  email_org: string;

  @Column({ length: 50, nullable: true })
  email_personal: string;

  @Column({ type: 'date', nullable: true })
  dob: Date;

  @Column({ length: 200, nullable: true })
  address: string;

  @Column({ length: 10, nullable: true })
  qualification: string;

  @Column({ type: 'date', nullable: true })
  join_date: Date;

  @Column({ length: 20, nullable: true })
  pan: string;

  @Column({ type: 'bigint', nullable: true })
  aadhar: number;

  @Column({ length: 255, nullable: true })
  profile_photo_path: string;

  @Column({ nullable: true })
  dept_id: number;

  @Column({ nullable: true })
  designation_id: number;

  @Column({ nullable: true })
  job_role_id: number;

  @Column({ default: true })
  active: boolean;

  @Column({ type: 'timestamp', default: () => 'now()' })
  created_at: Date;

  @Column({ type: 'timestamp', default: () => 'now()' })
  updated_at: Date;
}