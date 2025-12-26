# MRIT Hub - Windows Deployment Guide

## Prerequisites

1. **Install Docker Desktop for Windows**
   - Download: https://www.docker.com/products/docker-desktop/
   - Enable WSL 2 backend during installation
   - Restart computer after installation

2. **Install Git for Windows**
   - Download: https://git-scm.com/download/win
   - Use default settings during installation

## Deployment Steps

### 1. Clone Repository

Open PowerShell or Command Prompt:

```powershell
cd C:\
git clone https://github.com/irfan1476/mrit-hub.git
cd mrit-hub
```

### 2. Configure Environment

```powershell
# Copy environment template
copy .env.example .env

# Edit .env file with Notepad
notepad .env
```

Update these values in `.env`:
```
JWT_SECRET=your-secret-key-here
SMS_GATEWAY_URL=your-sms-gateway-url
SMS_GATEWAY_API_KEY=your-api-key
DATABASE_URL=postgresql://mrit_admin:mrit_secure_2024@postgres:5432/mrit_hub
```

### 3. Start Services

```powershell
# Start all services
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### 4. Verify Installation

```powershell
# Check database tables
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "\dt"

# Test backend API
curl http://localhost:3000/api/v1/health

# Or open in browser
start http://localhost:8080/admin.html
```

### 5. Access Points

- **Admin Panel**: http://localhost:8080/admin.html
- **Backend API**: http://localhost:3000
- **Database**: localhost:5432

**Admin Login:**
- Email: `admin@mrit.ac.in`
- Password: `admin123`

## Windows-Specific Commands

### PowerShell Commands

```powershell
# Stop services
docker-compose down

# Restart services
docker-compose restart

# View logs
docker-compose logs backend
docker-compose logs postgres

# Database access
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub

# Copy files to nginx
docker cp frontend\admin.html mrit-nginx:/usr/share/nginx/html/
docker cp frontend\config.js mrit-nginx:/usr/share/nginx/html/
```

### Troubleshooting

**Docker not starting:**
- Enable Virtualization in BIOS
- Enable WSL 2: `wsl --install`
- Restart Docker Desktop

**Port conflicts:**
Edit `docker-compose.yml` and change port mappings:
```yaml
ports:
  - "8081:80"  # Change 8080 to 8081
```

**Database connection issues:**
```powershell
docker-compose restart postgres
docker-compose logs postgres
```

**Clear all data:**
```powershell
docker-compose down -v
docker-compose up -d
```

## File Paths (Windows)

- Project root: `C:\mrit-hub\`
- Backend: `C:\mrit-hub\backend\`
- Frontend: `C:\mrit-hub\frontend\`
- Database: `C:\mrit-hub\database\`

## Development on Windows

### Backend Development

```powershell
cd backend
npm install
npm run start:dev
```

### Update Frontend

```powershell
# Edit files in frontend\ folder
# Then copy to nginx container
docker cp frontend\admin.html mrit-nginx:/usr/share/nginx/html/
docker cp frontend\admin-panel.html mrit-nginx:/usr/share/nginx/html/
docker cp frontend\config.js mrit-nginx:/usr/share/nginx/html/
```

## Backup & Restore

### Backup Database

```powershell
docker exec mrit-postgres pg_dump -U mrit_admin mrit_hub > backup.sql
```

### Restore Database

```powershell
Get-Content backup.sql | docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub
```

## Production Deployment

1. Update `.env` with production values
2. Change `NODE_ENV=production`
3. Update `frontend/config.js` with production domain
4. Use proper SSL certificates in nginx
5. Set strong passwords for database

## Support

- Documentation: `C:\mrit-hub\docs\`
- GitHub: https://github.com/irfan1476/mrit-hub
- Issues: https://github.com/irfan1476/mrit-hub/issues
