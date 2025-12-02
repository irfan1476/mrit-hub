import { IsOptional, IsString, IsDateString, IsEnum } from 'class-validator';

export enum ReportType {
  STUDENT_WISE = 'student_wise',
  SUBJECT_WISE = 'subject_wise',
  DEFAULTERS = 'defaulters'
}

export class AttendanceReportDto {
  @IsOptional()
  @IsString()
  department?: string;

  @IsOptional()
  @IsString()
  semester?: string;

  @IsOptional()
  @IsString()
  section?: string;

  @IsOptional()
  @IsString()
  subject_code?: string;

  @IsOptional()
  @IsDateString()
  from_date?: string;

  @IsOptional()
  @IsDateString()
  to_date?: string;

  @IsEnum(ReportType)
  @IsOptional()
  report_type?: ReportType = ReportType.STUDENT_WISE;
}