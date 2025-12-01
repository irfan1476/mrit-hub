import { Controller, Get } from '@nestjs/common';

@Controller()
export class AppController {
  @Get()
  getHello(): string {
    return 'MRIT Hub API v1 - Authentication Module Ready';
  }

  @Get('health')
  getHealth() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      service: 'mrit-hub-api',
      version: '1.0.0',
    };
  }
}