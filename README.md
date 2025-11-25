# MRIT Hub v1 - College Management System

A comprehensive, locally-hosted college management system with attendance tracking, student information management, and identity verification.

## 🏗️ Architecture

- **Backend**: NestJS + TypeScript
- **Database**: PostgreSQL 15
- **Cache/Queue**: Redis + Bull
- **Reverse Proxy**: Nginx
- **Deployment**: Docker + Docker Compose

## 📋 Features (MVP)

### 1. Attendance Management System (AMS)
- Faculty attendance capture with 36-hour edit window
- Real-time SMS alerts to parents on absence
- Defaulter reports and analytics
- Student self-view dashboard
- Complete audit trail

### 2. Identity Verification & Profile Management
- Google OAuth authentication
- Phone OTP verification
- Profile photo upload with secure serving
- Role-based access control

### 3. Student Information System (SIS-lite)
- Master data views
- Mentor-mentee mapping
- Department and section-wise filtering
- HOD dashboards

### 4. Account Request System
- Workspace password reset workflows
- Ticket tracking
- Email notifications

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 20+ (for local development)
- PostgreSQL client (optional, for direct DB access)

### Setup

1. **Clone and navigate**:
```bash
cd mrit-hub
```

2. **Create environment file**:
```bash
cp .env.example .env
# Edit .env with your credentials
```

3. **Start all services**:
```bash
docker-compose up -d
```

4. **Verify services**:
```bash
docker-compose ps
```

5. **Check logs**:
```bash
docker-compose logs -f backend
```

### Access Points

- **Backend API**: http://localhost:3000
- **Nginx Proxy**: http://localhost:80
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

## 📊 Database

### Schema
- **27 tables** covering students, faculty, courses, attendance, and notifications
- Complete relational model with proper indexes
- Automatic timestamps and audit triggers

### Seed Data
Initial data includes:
- Departments (CSE, ECE, ME, etc.)
- Schemes (2015, 2017, 2018, 2021, 2022)
- Semesters (1-8)
- Sections (A, B, C, D)
- Academic years
- Sample faculty and SMS templates

## 🔧 Development

### Install backend dependencies:
```bash
cd backend
npm install
```

### Run backend locally (without Docker):
```bash
cd backend
npm run start:dev
```

### Database migrations:
```bash
# Migrations are auto-run on container startup
# Manual execution:
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub < database/init/01-schema.sql
```

## 📁 Project Structure

```
mrit-hub/
├── backend/              # NestJS application
│   ├── src/
│   │   ├── modules/     # Feature modules
│   │   ├── common/      # Shared utilities
│   │   └── main.ts      # Entry point
│   ├── Dockerfile
│   └── package.json
├── database/
│   ├── init/            # Schema and seed data
│   └── migrations/      # Future migrations
├── nginx/
│   └── nginx.conf       # Reverse proxy config
├── docs/                # Documentation
├── docker-compose.yml   # Service orchestration
└── .env.example         # Environment template
```

## 🔐 Security

- Google OAuth for authentication
- JWT tokens for session management
- Role-based access control (RBAC)
- Secure file storage with authenticated access
- SQL injection protection via TypeORM
- CORS configuration
- Rate limiting (to be implemented)

## 📈 Scaling

The system is designed to handle:
- **1500+ users** (students, faculty, staff)
- **200-300 concurrent users** during peak times
- **Real-time SMS** processing via async queues

## 🛠️ Tech Stack Details

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Backend Framework | NestJS | API development |
| Language | TypeScript | Type safety |
| Database | PostgreSQL 15 | Relational data |
| ORM | TypeORM | Database abstraction |
| Cache/Queue | Redis + Bull | Async tasks, SMS |
| Auth | Passport.js | Google OAuth, JWT |
| File Upload | Multer | Profile photos |
| Reverse Proxy | Nginx | Load balancing, SSL |
| Containerization | Docker | Deployment |

## 📝 API Documentation

API documentation will be available at:
- Swagger UI: http://localhost:3000/api/docs (to be implemented)

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Coverage
npm run test:cov
```

## 📞 Support

For issues or questions:
- Email: support@mrit.ac.in
- Internal: IT Helpdesk

## 📄 License

Proprietary - MRIT Internal Use Only

---

**Status**: Phase 0 Complete - Foundation Setup ✅  
**Next**: Phase 1 - Authentication Module
