import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async findByEmail(email: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email } });
  }

  async createUser(userData: {
    email: string;
    passwordHash: string;
    role: UserRole;
    studentId?: number;
    facultyId?: number;
    emailVerificationToken?: string;
  }): Promise<User> {
    const user = this.usersRepository.create({
      email: userData.email,
      password_hash: userData.passwordHash,
      role: userData.role,
      student_id: userData.studentId,
      faculty_id: userData.facultyId,
      email_verification_token: userData.emailVerificationToken,
    });
    
    return this.usersRepository.save(user);
  }

  async findByEmailVerificationToken(token: string): Promise<User | null> {
    return this.usersRepository.findOne({ where: { email_verification_token: token } });
  }

  async findByPasswordResetToken(token: string): Promise<User | null> {
    return this.usersRepository.findOne({ 
      where: { 
        password_reset_token: token,
        password_reset_expires: { $gt: new Date() } as any
      } 
    });
  }

  async verifyEmail(userId: number): Promise<void> {
    await this.usersRepository.update(userId, {
      email_verified: true,
      email_verification_token: null,
    });
  }

  async setPasswordResetToken(userId: number, token: string, expires: Date): Promise<void> {
    await this.usersRepository.update(userId, {
      password_reset_token: token,
      password_reset_expires: expires,
    });
  }

  async resetPassword(userId: number, passwordHash: string): Promise<void> {
    await this.usersRepository.update(userId, {
      password_hash: passwordHash,
      password_reset_token: null,
      password_reset_expires: null,
    });
  }

  async updateRefreshToken(userId: number, refreshTokenHash: string | null): Promise<void> {
    await this.usersRepository.update(userId, { refresh_token_hash: refreshTokenHash });
  }

  async findById(id: number): Promise<User | null> {
    return this.usersRepository.findOne({ where: { id } });
  }
}