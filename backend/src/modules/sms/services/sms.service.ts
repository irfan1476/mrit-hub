import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SmsTemplate } from '../entities/sms-template.entity';
import { SmsLog } from '../entities/sms-log.entity';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class SmsService {
  constructor(
    @InjectRepository(SmsTemplate)
    private templateRepo: Repository<SmsTemplate>,
    @InjectRepository(SmsLog)
    private logRepo: Repository<SmsLog>,
    private configService: ConfigService,
  ) {}

  async sendAbsentNotification(studentName: string, parentPhone: string, subject: string, date: string) {
    const template = await this.templateRepo.findOne({
      where: { template_name: 'ABSENT_NOTIFICATION' }
    });

    if (!template) {
      throw new Error('SMS template not found');
    }

    const message = template.message_template
      .replace('{student_name}', studentName)
      .replace('{subject}', subject)
      .replace('{date}', date);

    const smsResult = await this.sendSms(parentPhone, message);

    // Log SMS
    await this.logRepo.save({
      phone: parentPhone,
      message: message,
      template_name: 'ABSENT_NOTIFICATION',
      status: smsResult.success ? 'SENT' as any : 'FAILED' as any,
      response: JSON.stringify(smsResult),
    });

    return smsResult;
  }

  private async sendSms(phoneNumber: string, message: string) {
    const gatewayUrl = this.configService.get('SMS_GATEWAY_URL');
    const apiKey = this.configService.get('SMS_GATEWAY_API_KEY');

    if (!gatewayUrl || !apiKey) {
      console.log(`SMS Mock: ${phoneNumber} - ${message}`);
      return { success: true, messageId: 'mock_' + Date.now() };
    }

    try {
      const response = await fetch(gatewayUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          to: phoneNumber,
          message: message,
        }),
      });

      const result = await response.json();
      return { success: response.ok, ...result };
    } catch (error) {
      return { success: false, error: error.message };
    }
  }
}