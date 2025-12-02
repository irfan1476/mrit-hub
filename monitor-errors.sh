#!/bin/bash

echo "🔍 MRIT Hub Error Monitor"
echo "========================="

# Check for TypeScript compilation errors
echo "📝 TypeScript Errors:"
docker-compose logs backend | grep -E "(error|Error|ERROR)" | tail -5

echo ""
echo "🗄️ Database Errors:"
docker-compose logs postgres | grep -E "(ERROR|FATAL)" | tail -5

echo ""
echo "📊 Service Status:"
docker-compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🌐 API Health Check:"
curl -s http://localhost:3000/api/v1/health | jq '.' 2>/dev/null || echo "API not responding"

echo ""
echo "📈 Recent Activity:"
docker-compose logs --tail=10 backend | grep -E "(LOG|ERROR|WARN)"