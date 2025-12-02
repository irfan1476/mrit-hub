import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { TimeSlot } from './time-slot.entity';

@Entity('timetable')
export class Timetable {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  course_offering_id: number;

  @Column()
  day_of_week: number; // 1=Monday, 7=Sunday

  @Column()
  time_slot_id: number;

  @Column({ length: 20, nullable: true })
  room_number: string;

  @Column({ type: 'date' })
  effective_from: Date;

  @Column({ type: 'date', nullable: true })
  effective_to: Date;

  @Column({ default: true })
  active: boolean;

  @Column({ type: 'timestamp', default: () => 'now()' })
  created_at: Date;

  @Column({ type: 'timestamp', default: () => 'now()' })
  updated_at: Date;

  @ManyToOne(() => TimeSlot)
  @JoinColumn({ name: 'time_slot_id' })
  time_slot: TimeSlot;
}