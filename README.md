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
- Git

### Setup

1. **Clone repository**:
```bash
git clone https://github.com/irfan1476/mrit-hub.git
cd mrit-hub
```

2. **Configure environment**:
```bash
cp .env.example .env
# Edit .env with your credentials:
# - GOOGLE_CLIENT_ID
# - GOOGLE_CLIENT_SECRET
# - SMS_GATEWAY_URL
# - SMS_GATEWAY_API_KEY
# - JWT_SECRET
```

3. **Start all services**:
```bash
./start.sh
# Or manually: docker-compose up -d
```

4. **Verify services**:
```bash
docker-compose ps
# All services should show "Up" or "healthy"
```

5. **Check database**:
```bash
docker exec -it mrit-postgres psql -U mrit_admin -d mrit_hub -c "\dt"
# Should list 27 tables
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

### Current Status
- ✅ Phase 0: Foundation Complete
- ⏳ Phase 1: Authentication Module (Next)
- ⏳ Phase 2-6: Pending

### Install backend dependencies:
```bash
cd backend
npm install
```

### Backend development (Phase 1+):
```bash
cd backend
npm run start:dev
# Backend will be available at http://localhost:3000
```

### Database access:
```bash
# Via Docker
docker exec -it mrit-postgres psql -U mrit_admin -d mrit_hub

# Common queries
\dt                                    # List tables
\d table_name                          # Describe table
SELECT COUNT(*) FROM department;      # Should return 10
```

### View logs:
```bash
docker-compose logs -f                # All services
docker-compose logs -f backend        # Backend only
docker-compose logs -f postgres       # Database only
```

## 📁 Project Structure

```
mrit-hub/
├── backend/                    # NestJS application
│   ├── src/                   # Source code (Phase 1+)
│   ├── Dockerfile             # Multi-stage build
│   ├── package.json           # Dependencies (30+)
│   └── tsconfig.json          # TypeScript config
├── database/
│   ├── init/
│   │   ├── 01-schema.sql     # 27 tables
│   │   └── 02-seed.sql       # Master data
│   └── migrations/            # Future migrations
├── nginx/
│   └── nginx.conf             # Reverse proxy
├── docs/
│   ├── DATABASE-ERD.md        # Schema documentation
│   ├── PHASE-0-COMPLETE.md    # Phase summary
│   └── GITHUB-SETUP.md        # Git guide
├── docker-compose.yml         # 4 services
├── .env.example               # Environment template
├── start.sh                   # Quick start script
├── verify.sh                  # Verification script
├── GETTING-STARTED.md         # Quick start guide
├── QUICK-REFERENCE.md         # Command reference
└── README.md                  # This file
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

## 📝 Documentation

- **README.md**: This file - project overview
- **GETTING-STARTED.md**: Quick start guide
- **QUICK-REFERENCE.md**: Common commands
- **STATUS.md**: Progress tracker
- **docs/DATABASE-ERD.md**: Complete schema
- **docs/PHASE-0-COMPLETE.md**: Foundation details
- **GITHUB-SETUP.md**: Git workflow

## 🧪 Testing (Phase 1+)

```bash
# Unit tests
cd backend
npm run test

# E2E tests
npm run test:e2e

# Coverage
npm run test:cov
```

## 📈 Development Roadmap

| Phase | Module | Status | Duration |
|-------|--------|--------|----------|
| Phase 0 | Foundation Setup | ✅ Complete | 1 day |
| Phase 1 | Authentication | ⏳ Pending | 4-6 hours |
| Phase 2 | Attendance System | ⏳ Pending | 5 days |
| Phase 3 | Identity Verification | ⏳ Pending | 2 days |
| Phase 4 | SIS-lite | ⏳ Pending | 1 day |
| Phase 5 | Account Requests | ⏳ Pending | 1 day |
| Phase 6 | Deployment | ⏳ Pending | 2 days |

**Overall Progress**: 8% (1/12 days)

## 🐛 Troubleshooting

### Services won't start
```bash
docker-compose down
docker-compose up -d
docker-compose logs
```

### Port conflicts
Edit `docker-compose.yml` and change port mappings

### Database connection failed
```bash
docker-compose restart postgres
docker-compose logs postgres
```

### Clear all data (CAUTION)
```bash
docker-compose down -v  # Removes volumes
```

## 📞 Support

For issues or questions:
- GitHub Issues: https://github.com/irfan1476/mrit-hub/issues
- Email: support@mrit.ac.in
- Documentation: See docs/ folder

## 📄 License

Proprietary - MRIT Internal Use Only

---

**Current Status**: ✅ Phase 0 Complete - Foundation Ready  
**Next Step**: Phase 1 - Authentication Module  
**Repository**: https://github.com/irfan1476/mrit-hub
