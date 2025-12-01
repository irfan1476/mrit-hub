import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';

export enum UserRole {
  STUDENT = 'STUDENT',
  FACULTY = 'FACULTY',
  MENTOR = 'MENTOR',
  HOD = 'HOD',
  ADMIN = 'ADMIN',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  email: string;

  @Column()
  password_hash: string;

  @Column({ type: 'enum', enum: UserRole })
  role: UserRole;

  @Column({ nullable: true })
  student_id: number;

  @Column({ nullable: true })
  faculty_id: number;

  @Column({ default: false })
  email_verified: boolean;

  @Column({ nullable: true })
  email_verification_token: string;

  @Column({ nullable: true })
  password_reset_token: string;

  @Column({ nullable: true })
  password_reset_expires: Date;

  @Column({ default: true })
  active: boolean;

  @Column({ nullable: true })
  refresh_token_hash: string;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}