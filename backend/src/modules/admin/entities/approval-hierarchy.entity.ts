import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('approval_hierarchy')
export class ApprovalHierarchy {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ nullable: true })
  department_id: number;

  @Column()
  level: number;

  @Column({ length: 20 })
  role_type: string;

  @Column({ nullable: true })
  designation_id: number;

  @Column({ default: true })
  is_active: boolean;

  @CreateDateColumn()
  created_at: Date;

  @UpdateDateColumn()
  updated_at: Date;
}