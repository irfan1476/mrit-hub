import { IsNotEmpty, IsDateString, IsNumber, IsString, IsOptional, Min } from 'class-validator';
import { Transform } from 'class-transformer';

export class ApplyLeaveDto {
  @IsNotEmpty()
  @IsNumber()
  leave_type_id: number;

  @IsNotEmpty()
  @IsDateString()
  from_date: string;

  @IsNotEmpty()
  @IsDateString()
  to_date: string;

  @IsNotEmpty()
  @IsNumber()
  @Min(0.5)
  @Transform(({ value }) => parseFloat(value))
  total_days: number;

  @IsNotEmpty()
  @IsString()
  reason: string;

  @IsOptional()
  @IsNumber()
  substitute_faculty_id?: number;
}