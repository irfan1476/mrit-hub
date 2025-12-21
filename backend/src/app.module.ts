import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AuthModule } from './modules/auth/auth.module';
import { UsersModule } from './modules/users/users.module';
import { EmailModule } from './modules/email/email.module';
import { AttendanceModule } from './modules/attendance/attendance.module';
import { SmsModule } from './modules/sms/sms.module';
import { LeaveModule } from './modules/leave/leave.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
import { AppController } from './app.controller';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      url: process.env.DATABASE_URL,
      autoLoadEntities: true,
      synchronize: false, // Use migrations in production
      logging: process.env.NODE_ENV === 'development',
      ssl: false,
    }),
    AuthModule,
    UsersModule,
    EmailModule,
    SmsModule,
    AttendanceModule,
    LeaveModule,
    DashboardModule,
  ],
  controllers: [AppController],
})
export class AppModule {}