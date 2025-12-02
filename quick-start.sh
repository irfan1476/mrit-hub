#!/bin/bash

echo "🚀 MRIT Hub Quick Start"

# Check if containers exist and are built
if docker images | grep -q "mrit-hub-backend"; then
    echo "✅ Using existing images..."
    docker-compose up -d
else
    echo "🔨 Building images (first time only)..."
    docker-compose up -d --build
fi

echo "⏳ Waiting for services..."
sleep 5

# Quick health check
echo "🔍 Service Status:"
docker-compose ps --format "table {{.Name}}\t{{.Status}}"

echo ""
echo "🌐 Access Points:"
echo "- Backend API: http://localhost:3000"
echo "- Nginx Proxy: http://localhost:80"
echo ""
echo "📊 Quick verify: curl http://localhost:3000/api/v1/health"