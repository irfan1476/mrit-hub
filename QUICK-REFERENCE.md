# MRIT Hub - Quick Reference

## 🚀 Quick Commands

### Start/Stop Services
```bash
./start.sh                    # Start all services
docker-compose up -d          # Start in background
docker-compose down           # Stop all services
docker-compose restart        # Restart services
docker-compose ps             # Check status
```

### View Logs
```bash
docker-compose logs -f                # All services
docker-compose logs -f backend        # Backend only
docker-compose logs -f postgres       # Database only
```

### Database Access
```bash
# Via Docker
docker exec -it mrit-postgres psql -U mrit_admin -d mrit_hub

# Common queries
\dt                           # List tables
\d table_name                 # Describe table
SELECT COUNT(*) FROM student_data;
```

### Redis Access
```bash
docker exec -it mrit-redis redis-cli
PING                          # Test connection
KEYS *                        # List all keys
```

### Backend Development
```bash
cd backend
npm install                   # Install dependencies
npm run start:dev             # Run in dev mode
npm run build                 # Build for production
```

### Git Commands
```bash
git status                    # Check changes
git add .                     # Stage all changes
git commit -m "message"       # Commit changes
git push origin main          # Push to GitHub
git log --oneline             # View commit history
```

## 📁 Important Files

| File | Purpose |
|------|---------|
| `.env` | Environment variables (credentials) |
| `docker-compose.yml` | Service orchestration |
| `database/init/01-schema.sql` | Database schema (27 tables) |
| `database/init/02-seed.sql` | Master data |
| `backend/package.json` | Backend dependencies |
| `nginx/nginx.conf` | Reverse proxy config |

## 🔗 Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| Backend API | http://localhost:3000 | - |
| Nginx Proxy | http://localhost:80 | - |
| PostgreSQL | localhost:5432 | mrit_admin / (see .env) |
| Redis | localhost:6379 | - |

## 📊 Database Tables (27)

**Master (14):** grad_year, gender, reservation, admission, entry, batch, department, scheme, coursecat, semester, academic_year, financial_year, exam_type, section

**Core (4):** faculty, student_data, student_variables, placement

**Academic (2):** course, course_offering

**Attendance (4):** attendance_session, attendance_record, attendance_log, attendance_summary

**Notifications (3):** sms_template, sms_log, notification_preference

## 🐛 Troubleshooting

### Services won't start
```bash
docker-compose down
docker-compose up -d
docker-compose logs
```

### Port conflicts
Edit `docker-compose.yml` ports section

### Database connection failed
```bash
docker-compose restart postgres
docker-compose logs postgres
```

### Clear all data (CAUTION)
```bash
docker-compose down -v  # Removes volumes
```

## 📝 Project Structure

```
mrit-hub/
├── backend/          # NestJS application
├── database/         # SQL schema & migrations
├── nginx/            # Reverse proxy
├── docs/             # Documentation
├── .env              # Environment config
└── docker-compose.yml
```

## 🎯 Development Workflow

1. Make changes to code
2. Test locally
3. Commit: `git add . && git commit -m "message"`
4. Push: `git push origin main`
5. Deploy (when ready)

## 📞 Support

- **Documentation**: See README.md, GETTING-STARTED.md
- **Database Schema**: See docs/DATABASE-ERD.md
- **Phase Status**: See STATUS.md
- **GitHub Setup**: See GITHUB-SETUP.md

---

**Quick Start:** `./start.sh`  
**Verify:** `docker-compose ps`  
**Logs:** `docker-compose logs -f`
