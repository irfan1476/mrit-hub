import { IsNotEmpty, IsString, IsDateString, IsOptional } from 'class-validator';

export class CreateAttendanceSessionDto {
  @IsNotEmpty()
  @IsString()
  subject_code: string;

  @IsNotEmpty()
  @IsString()
  department: string;

  @IsNotEmpty()
  @IsString()
  semester: string;

  @IsNotEmpty()
  @IsString()
  section: string;

  @IsNotEmpty()
  @IsDateString()
  session_date: string;

  @IsNotEmpty()
  @IsString()
  time_slot: string;

  @IsOptional()
  @IsString()
  topic?: string;
}