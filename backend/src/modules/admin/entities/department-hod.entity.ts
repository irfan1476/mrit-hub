import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';
import { Faculty } from '../../leave/entities/faculty.entity';

@Entity('department_hod')
export class DepartmentHod {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  department_id: number;

  @Column()
  faculty_id: number;

  @Column({ type: 'date', default: () => 'CURRENT_DATE' })
  from_date: Date;

  @Column({ type: 'date', nullable: true })
  to_date: Date;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;

  @ManyToOne(() => Faculty)
  @JoinColumn({ name: 'faculty_id' })
  faculty: Faculty;
}