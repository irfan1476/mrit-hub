#!/bin/bash

echo "⚡ MRIT Hub - Fast Development Start"

# Use development compose file
docker-compose -f docker-compose.dev.yml up -d postgres redis

echo "⏳ Waiting for database..."
sleep 3

# Start backend in development mode
docker-compose -f docker-compose.dev.yml up -d backend-dev

echo "🚀 Services starting..."
echo "📊 Status:"
docker-compose -f docker-compose.dev.yml ps

echo ""
echo "🌐 Backend will be ready at: http://localhost:3000"
echo "📝 Logs: docker-compose -f docker-compose.dev.yml logs -f backend-dev"