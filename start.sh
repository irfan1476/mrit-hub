#!/bin/bash

echo "🚀 Starting MRIT Hub v1..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.example .env
    echo "✅ Created .env file. Please edit it with your credentials."
    echo "⚠️  IMPORTANT: Ensure DATABASE_URL uses 'postgres' as hostname:"
    echo "   DATABASE_URL=postgresql://mrit_admin:password@postgres:5432/mrit_hub"
    echo ""
fi

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 15

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "📁 Deploying frontend files..."
cd frontend
for file in *.html *.js *.jpg; do
    if [ -f "$file" ]; then
        docker cp "$file" mrit-nginx:/usr/share/nginx/html/
        echo "  ✓ Copied $file"
    fi
done
cd ..

echo ""
echo "✅ MRIT Hub is running!"
echo ""
echo "Access points:"
echo "  - Frontend: http://localhost:8080"
echo "  - Backend API: http://localhost:3000"
echo "  - PostgreSQL: localhost:5432"
echo "  - Redis: localhost:6379"
echo ""
echo "Login credentials:"
echo "  Email: faculty@mysururoyal.org"
echo "  Password: password123"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f backend"
echo ""
echo "To stop:"
echo "  docker-compose down"
echo ""
