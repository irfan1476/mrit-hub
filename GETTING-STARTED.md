# Getting Started with MRIT Hub v1

## 🎉 Phase 0: Foundation Setup - COMPLETE!

Your MRIT Hub project is ready for development.

## 📁 What's Been Created

```
mrit-hub/
├── backend/                      # NestJS backend (ready for code)
│   ├── Dockerfile               ✅
│   ├── package.json             ✅ (all dependencies defined)
│   ├── tsconfig.json            ✅
│   └── nest-cli.json            ✅
├── database/
│   └── init/
│       ├── 01-schema.sql        ✅ (27 tables)
│       └── 02-seed.sql          ✅ (master data)
├── nginx/
│   └── nginx.conf               ✅ (reverse proxy)
├── docs/
│   ├── PHASE-0-COMPLETE.md      ✅
│   └── DATABASE-ERD.md          ✅
├── docker-compose.yml           ✅ (4 services)
├── .env                         ✅ (from template)
├── .env.example                 ✅
├── .gitignore                   ✅
├── README.md                    ✅
├── start.sh                     ✅ (quick start script)
└── GETTING-STARTED.md           ✅ (this file)
```

## 🚀 Quick Start (3 Steps)

### Step 1: Configure Environment

Edit `.env` file with your credentials:

```bash
# Required for Phase 1 (Authentication):
JWT_SECRET=your_secure_jwt_secret

# Required for Phase 2 (SMS):
SMS_GATEWAY_URL=your_sms_gateway_url
SMS_GATEWAY_API_KEY=your_sms_api_key

# Generate a strong JWT secret:
JWT_SECRET=$(openssl rand -base64 32)
```

### Step 2: Start Services

```bash
./start.sh
```

Or manually:
```bash
docker-compose up -d
```

### Step 3: Verify

```bash
# Check all services are running
docker-compose ps

# Should show:
# - mrit-postgres (healthy)
# - mrit-redis (healthy)
# - mrit-backend (running)
# - mrit-nginx (running)

# Check database tables
docker exec -it mrit-postgres psql -U mrit_admin -d mrit_hub -c "\dt"

# Should list 27 tables

# Check seed data
docker exec -it mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) FROM department;"

# Should return: 10
```

## 📊 Service Details

| Service | Container | Port | Status |
|---------|-----------|------|--------|
| PostgreSQL | mrit-postgres | 5432 | ✅ Ready |
| Redis | mrit-redis | 6379 | ✅ Ready |
| Backend | mrit-backend | 3000 | ⏳ Needs code |
| Nginx | mrit-nginx | 80 | ✅ Ready |

## 🔧 Development Setup

### Install Backend Dependencies

```bash
cd backend
npm install
```

This will install:
- NestJS framework
- TypeORM (PostgreSQL)
- Passport (JWT authentication)
- Bull (async queue)
- And 20+ other dependencies

### Database Access

**Via Docker:**
```bash
docker exec -it mrit-postgres psql -U mrit_admin -d mrit_hub
```

**Via local client:**
```bash
psql -h localhost -p 5432 -U mrit_admin -d mrit_hub
# Password: mrit_secure_pass_2024 (or your custom password)
```

### Redis Access

```bash
docker exec -it mrit-redis redis-cli
```

## 📝 What's Next?

### Phase 1: Authentication Module (Next)

We'll build:
1. Email/password authentication
2. JWT token service
3. RBAC guards
4. Auth middleware

**Estimated time:** 4-6 hours

### Remaining Phases

- **Phase 2**: Attendance Management (5 days)
- **Phase 3**: Identity Verification (2 days)
- **Phase 4**: SIS-lite (1 day)
- **Phase 5**: Account Requests (1 day)
- **Phase 6**: Deployment (2 days)

**Total MVP:** ~12 days

## 🐛 Troubleshooting

### Services won't start

```bash
# Check Docker is running
docker --version

# Check logs
docker-compose logs

# Restart services
docker-compose down
docker-compose up -d
```

### Database connection issues

```bash
# Check PostgreSQL is healthy
docker-compose ps postgres

# Check logs
docker-compose logs postgres

# Restart PostgreSQL
docker-compose restart postgres
```

### Port conflicts

If ports 80, 3000, 5432, or 6379 are in use:

Edit `docker-compose.yml` and change port mappings:
```yaml
ports:
  - "8080:80"    # Change 80 to 8080
  - "3001:3000"  # Change 3000 to 3001
```

## 📚 Documentation

- **README.md**: Project overview
- **docs/PHASE-0-COMPLETE.md**: What was built in Phase 0
- **docs/DATABASE-ERD.md**: Complete database schema
- **Backend API docs**: Coming in Phase 1

## 🔐 Security Notes

**Before Production:**
1. Change all default passwords in `.env`
2. Generate strong JWT secret
3. Set up SSL certificates for Nginx
4. Configure firewall rules
5. Enable rate limiting
6. Set up monitoring

## 💡 Tips

1. **Keep Docker running**: Services auto-restart on system reboot
2. **Use logs**: `docker-compose logs -f backend` for debugging
3. **Database backups**: Set up regular backups of postgres_data volume
4. **Git**: Commit regularly, `.env` is already in `.gitignore`

## 🎯 Ready to Code?

When you're ready for Phase 1, just say:

**"Start Phase 1: Authentication"**

I'll create:
- Auth module structure
- Email/password authentication
- JWT service
- RBAC guards
- All necessary entities and DTOs

---

**Current Status**: ✅ Phase 0 Complete - Foundation Ready  
**Next Step**: Phase 1 - Authentication Module  
**Your Pace**: We proceed when you're ready 👍
