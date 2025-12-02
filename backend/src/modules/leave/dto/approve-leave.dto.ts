import { IsNotEmpty, IsEnum, IsOptional, IsString } from 'class-validator';
import { ApprovalDecision } from '../entities/leave-approval.entity';

export class ApproveLeaveDto {
  @IsNotEmpty()
  @IsEnum(ApprovalDecision)
  decision: ApprovalDecision;

  @IsOptional()
  @IsString()
  comment?: string;
}