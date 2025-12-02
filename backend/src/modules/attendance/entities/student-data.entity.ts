import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('student_data')
export class StudentData {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 12, unique: true })
  usn: string;

  @Column({ length: 50, nullable: true })
  student_name: string;

  @Column({ nullable: true })
  branch_id: number;

  @Column({ length: 15, nullable: true })
  phone: string;

  @Column({ length: 50, nullable: true })
  email: string;

  @Column({ type: 'date', nullable: true })
  dob: Date;

  @Column({ length: 50, nullable: true })
  father_name: string;

  @Column({ length: 15, nullable: true })
  father_phone: string;

  @Column({ length: 50, nullable: true })
  mother_name: string;

  @Column({ length: 15, nullable: true })
  alt_phone: string;

  @Column({ length: 15, nullable: true })
  parent_primary_phone: string;

  @Column({ length: 200, nullable: true })
  address: string;

  @Column({ length: 5, nullable: true })
  blood_group: string;

  @Column({ length: 255, nullable: true })
  profile_photo_path: string;

  @Column({ default: false })
  phone_verified: boolean;

  @Column({ nullable: true })
  gender_id: number;

  @Column({ nullable: true })
  batch_id: number;

  @Column({ nullable: true })
  entry_id: number;

  @Column({ nullable: true })
  res_cat_id: number;

  @Column({ nullable: true })
  adm_cat_id: number;

  @Column({ type: 'timestamp', default: () => 'now()' })
  created_at: Date;

  @Column({ type: 'timestamp', default: () => 'now()' })
  updated_at: Date;
}