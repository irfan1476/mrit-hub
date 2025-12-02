import { Entity, PrimaryGeneratedColumn, Column } from 'typeorm';

@Entity('time_slot')
export class TimeSlot {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 50 })
  slot_name: string;

  @Column({ type: 'time' })
  start_time: string;

  @Column({ type: 'time' })
  end_time: string;

  @Column()
  duration_hours: number;

  @Column({ length: 20 })
  slot_type: 'THEORY' | 'LAB' | 'TUTORIAL' | 'SEMINAR';

  @Column({ default: true })
  active: boolean;

  @Column({ type: 'timestamp', default: () => 'now()' })
  created_at: Date;
}