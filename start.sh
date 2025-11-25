#!/bin/bash

echo "🚀 Starting MRIT Hub v1..."
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.example .env
    echo "✅ Created .env file. Please edit it with your credentials."
    echo ""
fi

# Start Docker services
echo "🐳 Starting Docker services..."
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "✅ MRIT Hub is starting!"
echo ""
echo "Access points:"
echo "  - Backend API: http://localhost:3000"
echo "  - Nginx Proxy: http://localhost:80"
echo "  - PostgreSQL: localhost:5432"
echo "  - Redis: localhost:6379"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f backend"
echo ""
echo "To stop:"
echo "  docker-compose down"
echo ""
