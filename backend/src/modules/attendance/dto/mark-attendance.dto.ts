import { IsNotEmpty, IsString, IsEnum, IsArray, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export enum AttendanceStatusDto {
  PRESENT = 'PRESENT',
  ABSENT = 'ABSENT',
}

export class StudentAttendanceDto {
  @IsNotEmpty()
  @IsString()
  student_id: string;

  @IsEnum(AttendanceStatusDto)
  status: AttendanceStatusDto;
}

export class MarkAttendanceDto {
  @IsNotEmpty()
  @IsString()
  session_id: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => StudentAttendanceDto)
  attendance_records: StudentAttendanceDto[];
}