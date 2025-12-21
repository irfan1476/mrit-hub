import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('academic_year')
export class AcademicYear {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 30, unique: true })
  yr: string;
}