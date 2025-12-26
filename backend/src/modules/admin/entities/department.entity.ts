import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('department')
export class Department {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 5, unique: true })
  code: string;

  @Column({ length: 50, unique: true })
  dept_name: string;
}