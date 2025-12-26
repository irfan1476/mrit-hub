import { Injectable, UnauthorizedException, BadRequestException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { UsersService } from '../users/users.service';
import { EmailService } from '../email/email.service';
import { User, UserRole } from '../users/entities/user.entity';
import { RegisterDto, LoginDto, ForgotPasswordDto, ResetPasswordDto } from './dto/auth.dto';
import * as bcrypt from 'bcrypt';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);

  constructor(
    private usersService: UsersService,
    private emailService: EmailService,
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async register(registerDto: RegisterDto): Promise<{ message: string }> {
    const { email, password, firstName, lastName } = registerDto;
    
    // Validate domain
    if (!email.endsWith('@mysururoyal.org')) {
      throw new BadRequestException('Only @mysururoyal.org emails are allowed');
    }

    // Check if user exists
    const existingUser = await this.usersService.findByEmail(email);
    if (existingUser) {
      throw new BadRequestException('User already exists');
    }

    // Hash password
    const passwordHash = await bcrypt.hash(password, 12);
    
    // Generate verification token
    const emailVerificationToken = crypto.randomBytes(32).toString('hex');
    
    // Determine role
    const role = await this.determineUserRole(email);
    const { studentId, facultyId } = await this.getUserIds(email);

    // Create user
    const user = await this.usersService.createUser({
      email,
      passwordHash,
      role,
      studentId,
      facultyId,
      emailVerificationToken,
    });

    // Send verification email
    await this.emailService.sendVerificationEmail(email, emailVerificationToken);
    
    this.logger.log(`New user registered: ${email}`);
    return { message: 'Registration successful. Please check your email to verify your account.' };
  }

  async login(loginDto: LoginDto): Promise<any> {
    const { email, password } = loginDto;
    
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.active) {
      throw new UnauthorizedException('Account is deactivated');
    }

    if (!user.email_verified) {
      throw new UnauthorizedException('Please verify your email before logging in');
    }

    this.logger.log(`User logged in: ${email}`);
    return this.generateTokens(user);
  }

  async verifyEmail(token: string): Promise<{ message: string }> {
    const user = await this.usersService.findByEmailVerificationToken(token);
    if (!user) {
      throw new BadRequestException('Invalid or expired verification token');
    }

    await this.usersService.verifyEmail(user.id);
    this.logger.log(`Email verified for user: ${user.email}`);
    
    return { message: 'Email verified successfully. You can now log in.' };
  }

  async forgotPassword(forgotPasswordDto: ForgotPasswordDto): Promise<{ message: string }> {
    const { email } = forgotPasswordDto;
    
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      // Don't reveal if email exists
      return { message: 'If the email exists, a password reset link has been sent.' };
    }

    const resetToken = crypto.randomBytes(32).toString('hex');
    const resetExpires = new Date(Date.now() + 3600000); // 1 hour

    await this.usersService.setPasswordResetToken(user.id, resetToken, resetExpires);
    await this.emailService.sendPasswordResetEmail(email, resetToken);
    
    this.logger.log(`Password reset requested for: ${email}`);
    return { message: 'If the email exists, a password reset link has been sent.' };
  }

  async resetPassword(resetPasswordDto: ResetPasswordDto): Promise<{ message: string }> {
    const { token, password } = resetPasswordDto;
    
    const user = await this.usersService.findByPasswordResetToken(token);
    if (!user || user.password_reset_expires < new Date()) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    const passwordHash = await bcrypt.hash(password, 12);
    await this.usersService.resetPassword(user.id, passwordHash);
    
    this.logger.log(`Password reset completed for: ${user.email}`);
    return { message: 'Password reset successfully.' };
  }

  private async generateTokens(user: User) {
    const payload = { 
      email: user.email, 
      sub: user.id, 
      role: user.role 
    };

    const accessToken = this.jwtService.sign(payload, { expiresIn: '15m' });
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });
    
    // Hash and store refresh token
    const refreshTokenHash = await bcrypt.hash(refreshToken, 10);
    await this.usersService.updateRefreshToken(user.id, refreshTokenHash);

    return {
      accessToken,
      refreshToken,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        emailVerified: user.email_verified,
        studentId: user.student_id,
        facultyId: user.faculty_id,
      },
    };
  }

  async refreshTokens(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken);
      const user = await this.usersService.findById(payload.sub);
      
      if (!user || !user.refresh_token_hash) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      const isValidRefreshToken = await bcrypt.compare(refreshToken, user.refresh_token_hash);
      if (!isValidRefreshToken) {
        throw new UnauthorizedException('Invalid refresh token');
      }

      return this.generateTokens(user);
    } catch (error) {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  async logout(userId: number) {
    await this.usersService.updateRefreshToken(userId, null);
  }

  async demoLogin(loginDto: LoginDto): Promise<any> {
    const { email, password } = loginDto;
    
    const user = await this.usersService.findByEmail(email);
    if (!user) {
      throw new UnauthorizedException('Invalid credentials');
    }

    if (!user.active) {
      throw new UnauthorizedException('Account is deactivated');
    }

    this.logger.log(`Demo login: ${email}`);
    return this.generateTokens(user);
  }

  private async determineUserRole(email: string): Promise<UserRole> {
    // Check if faculty exists
    // Note: This would need actual faculty table query
    // For now, defaulting to STUDENT
    return UserRole.STUDENT;
  }

  private async getUserIds(email: string): Promise<{ studentId?: number; facultyId?: number }> {
    // Check student_data and faculty tables
    // For now, returning empty
    return {};
  }
}