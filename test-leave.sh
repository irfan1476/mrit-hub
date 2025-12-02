#!/bin/bash

echo "🏛️ MRIT Hub - Leave Management System Test"
echo "=========================================="

API_BASE="http://localhost:3000/api/v1"

echo "📋 Testing Leave Management Endpoints:"
echo ""

echo "1. Leave Types (Public):"
curl -s "$API_BASE/leave/types" | jq '.' 2>/dev/null || echo "Requires authentication"

echo ""
echo "2. Health Check:"
curl -s "$API_BASE/health" | jq '.'

echo ""
echo "3. Database Verification:"
echo "   - Leave Types:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) as leave_types FROM leave_type WHERE active = true;"

echo "   - Leave Balances:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) as leave_balances FROM leave_balance;"

echo "   - Leave Applications:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) as applications FROM leave_application;"

echo ""
echo "🌐 Frontend Access:"
echo "   - Leave Management UI: file://$(pwd)/frontend/leave.html"
echo ""
echo "📊 API Endpoints Available:"
echo "   GET  /api/v1/leave/types"
echo "   GET  /api/v1/leave/balance"
echo "   POST /api/v1/leave/apply"
echo "   GET  /api/v1/leave/my-applications"
echo "   GET  /api/v1/leave/pending-approvals/substitute"
echo "   GET  /api/v1/leave/pending-approvals/hod"
echo "   POST /api/v1/leave/approve/:id/substitute"
echo "   POST /api/v1/leave/approve/:id/hod"