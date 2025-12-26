import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('designation')
export class Designation {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 100 })
  des_name: string;
}