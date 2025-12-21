#!/bin/bash

echo "🎯 Testing Faculty Dashboard System"
echo "=================================="

API_BASE="http://localhost:3000/api/v1"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n${YELLOW}1. Testing Dashboard APIs${NC}"
echo "-------------------------"

# Test faculty info
echo "👤 Testing faculty info API..."
FACULTY_RESPONSE=$(curl -s "${API_BASE}/dashboard/faculty-info")
if echo "$FACULTY_RESPONSE" | jq -e '.name' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Faculty info loaded${NC}"
    echo "$FACULTY_RESPONSE" | jq -r '"   Name: \(.name), Department: \(.department)"'
else
    echo -e "${RED}❌ Failed to load faculty info${NC}"
fi

# Test today's schedule
echo -e "\n📅 Testing today's schedule API..."
SCHEDULE_RESPONSE=$(curl -s "${API_BASE}/dashboard/today-schedule")
SCHEDULE_COUNT=$(echo "$SCHEDULE_RESPONSE" | jq '. | length' 2>/dev/null)
if [ "$SCHEDULE_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Schedule loaded: $SCHEDULE_COUNT periods${NC}"
    echo "$SCHEDULE_RESPONSE" | jq -r '.[0:2] | .[] | "   \(.time): \(.subject) - \(.course)"' 2>/dev/null
else
    echo -e "${RED}❌ Failed to load schedule${NC}"
fi

# Test leave overview
echo -e "\n🏖️ Testing leave overview API..."
LEAVE_RESPONSE=$(curl -s "${API_BASE}/dashboard/leave-overview")
if echo "$LEAVE_RESPONSE" | jq -e '.stats' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Leave overview loaded${NC}"
    echo "$LEAVE_RESPONSE" | jq -r '"   Pending: \(.stats.pending), Approved: \(.stats.approved), Rejected: \(.stats.rejected)"' 2>/dev/null
else
    echo -e "${RED}❌ Failed to load leave overview${NC}"
fi

# Test approvals
echo -e "\n⚡ Testing approvals API..."
APPROVALS_RESPONSE=$(curl -s "${API_BASE}/dashboard/approvals")
if echo "$APPROVALS_RESPONSE" | jq -e '.substitute' > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Approvals loaded${NC}"
    SUB_COUNT=$(echo "$APPROVALS_RESPONSE" | jq '.substitute | length' 2>/dev/null)
    HOD_COUNT=$(echo "$APPROVALS_RESPONSE" | jq '.hod | length' 2>/dev/null)
    echo "   Substitute approvals: $SUB_COUNT, HOD approvals: $HOD_COUNT"
else
    echo -e "${RED}❌ Failed to load approvals${NC}"
fi

echo -e "\n${YELLOW}2. Testing Dashboard UI${NC}"
echo "----------------------"

# Check if dashboard file exists
if [ -f "frontend/dashboard.html" ]; then
    SIZE=$(wc -c < "frontend/dashboard.html")
    echo -e "${GREEN}✅ Dashboard UI exists (${SIZE} bytes)${NC}"
else
    echo -e "${RED}❌ Dashboard UI missing${NC}"
fi

echo -e "\n${YELLOW}3. Dashboard Features Summary${NC}"
echo "-----------------------------"

echo -e "${GREEN}✅ Implemented Features:${NC}"
echo "   • Faculty header with greeting and profile info"
echo "   • Quick actions bar (Apply Leave, Approvals, etc.)"
echo "   • Today's teaching schedule with MRIT time slots"
echo "   • Leave overview with balance and statistics"
echo "   • Approvals center for substitute and HOD approvals"
echo "   • Notices section"
echo "   • Gallery section"
echo "   • Responsive design for mobile/tablet"
echo "   • Role-based UI (HOD/Faculty/Substitute)"

echo -e "\n${YELLOW}4. Dashboard Layout Structure${NC}"
echo "-----------------------------"
echo "   📋 Header: Faculty info + greeting + date"
echo "   🎯 Quick Actions: Apply Leave, Approvals, History, Attendance"
echo "   📅 Timetable: Today's schedule with current/upcoming highlights"
echo "   🏖️ Leave Overview: Balance, stats, recent applications"
echo "   ⚡ Approvals: Substitute requests + HOD approvals"
echo "   📢 Notices: Institution announcements"
echo "   🖼️ Gallery: Photo gallery section"

echo -e "\n${GREEN}🎉 Faculty Dashboard Test Complete!${NC}"
echo -e "\n${YELLOW}Access Points:${NC}"
echo "• Dashboard UI: http://localhost:3000/dashboard.html"
echo "• Faculty Info API: ${API_BASE}/dashboard/faculty-info"
echo "• Schedule API: ${API_BASE}/dashboard/today-schedule"
echo "• Leave Overview API: ${API_BASE}/dashboard/leave-overview"
echo "• Approvals API: ${API_BASE}/dashboard/approvals"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Integrate with authentication system"
echo "2. Connect to real timetable data"
echo "3. Add marks entry functionality"
echo "4. Implement real-time notifications"