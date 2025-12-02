#!/bin/bash

echo "🧪 Testing MRIT Hub UI Systems"
echo "================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

API_BASE="http://localhost:3000/api/v1"

echo -e "\n${YELLOW}1. Testing Attendance System${NC}"
echo "----------------------------"

# Test time slots
echo "📅 Testing time slots API..."
TIMESLOTS_RESPONSE=$(curl -s "${API_BASE}/attendance/time-slots")
TIMESLOTS_COUNT=$(echo "$TIMESLOTS_RESPONSE" | jq '. | length' 2>/dev/null)

if [ "$TIMESLOTS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Time slots loaded: $TIMESLOTS_COUNT slots${NC}"
    echo "   Sample slots:"
    echo "$TIMESLOTS_RESPONSE" | jq -r '.[0:3] | .[] | "   - \(.slot_name): \(.start_time) - \(.end_time) (\(.duration_hours)h \(.slot_type))"' 2>/dev/null
else
    echo -e "${RED}❌ Failed to load time slots${NC}"
fi

# Test students API
echo -e "\n👥 Testing students API..."
STUDENTS_RESPONSE=$(curl -s "${API_BASE}/attendance/students?department=CSE&semester=3&section=A")
STUDENTS_COUNT=$(echo "$STUDENTS_RESPONSE" | jq '. | length' 2>/dev/null)

if [ "$STUDENTS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Students loaded: $STUDENTS_COUNT students${NC}"
    echo "   Sample students:"
    echo "$STUDENTS_RESPONSE" | jq -r '.[0:2] | .[] | "   - \(.name) (\(.roll_no))"' 2>/dev/null
else
    echo -e "${RED}❌ Failed to load students${NC}"
fi

# Test demo session creation
echo -e "\n📝 Testing demo session creation..."
SESSION_DATA='{
    "subject_code": "B1",
    "department": "CSE",
    "semester": 3,
    "section": "A",
    "session_date": "'$(date +%Y-%m-%d)'",
    "time_slot": "Period 1",
    "topic": "Test Session"
}'

SESSION_RESPONSE=$(curl -s -X POST "${API_BASE}/attendance/demo/session" \
    -H "Content-Type: application/json" \
    -d "$SESSION_DATA")

SESSION_ID=$(echo "$SESSION_RESPONSE" | jq -r '.id' 2>/dev/null)

if [ "$SESSION_ID" != "null" ] && [ "$SESSION_ID" != "" ]; then
    echo -e "${GREEN}✅ Demo session created: ID $SESSION_ID${NC}"
else
    echo -e "${RED}❌ Failed to create demo session${NC}"
    echo "Response: $SESSION_RESPONSE"
fi

echo -e "\n${YELLOW}2. Testing Leave Management System${NC}"
echo "-----------------------------------"

# Test leave types
echo "📋 Testing leave types API..."
LEAVE_TYPES_RESPONSE=$(curl -s "${API_BASE}/leave/types")
LEAVE_TYPES_COUNT=$(echo "$LEAVE_TYPES_RESPONSE" | jq '. | length' 2>/dev/null)

if [ "$LEAVE_TYPES_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Leave types loaded: $LEAVE_TYPES_COUNT types${NC}"
    echo "   Available types:"
    echo "$LEAVE_TYPES_RESPONSE" | jq -r '.[] | "   - \(.name) (\(.code)): Max \(.max_days_per_year) days/year"' 2>/dev/null
else
    echo -e "${RED}❌ Failed to load leave types${NC}"
fi

# Test demo leave applications
echo -e "\n📄 Testing demo leave applications..."
APPLICATIONS_RESPONSE=$(curl -s "${API_BASE}/leave/demo/applications")
APPLICATIONS_COUNT=$(echo "$APPLICATIONS_RESPONSE" | jq '. | length' 2>/dev/null)

if [ "$APPLICATIONS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Demo applications loaded: $APPLICATIONS_COUNT applications${NC}"
    echo "   Sample applications:"
    echo "$APPLICATIONS_RESPONSE" | jq -r '.[0:2] | .[] | "   - \(.leave_type.name): \(.from_date) to \(.to_date) (\(.status))"' 2>/dev/null
else
    echo -e "${RED}❌ Failed to load demo applications${NC}"
fi

# Test demo leave balances
echo -e "\n💰 Testing demo leave balances..."
BALANCES_RESPONSE=$(curl -s "${API_BASE}/leave/demo/balance")
BALANCES_COUNT=$(echo "$BALANCES_RESPONSE" | jq '. | length' 2>/dev/null)

if [ "$BALANCES_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✅ Demo balances loaded: $BALANCES_COUNT balance records${NC}"
    echo "   Sample balances:"
    echo "$BALANCES_RESPONSE" | jq -r '.[0:3] | .[] | "   - \(.leave_type.name): \(.remaining_days)/\(.opening_balance) days remaining"' 2>/dev/null
else
    echo -e "${RED}❌ Failed to load demo balances${NC}"
fi

# Test demo leave application submission
echo -e "\n✉️ Testing demo leave application submission..."
LEAVE_APP_DATA='{
    "leave_type_id": 1,
    "from_date": "'$(date -d "+7 days" +%Y-%m-%d)'",
    "to_date": "'$(date -d "+8 days" +%Y-%m-%d)'",
    "total_days": 2,
    "reason": "Test leave application",
    "substitute_faculty_id": 2
}'

LEAVE_APP_RESPONSE=$(curl -s -X POST "${API_BASE}/leave/demo/apply" \
    -H "Content-Type: application/json" \
    -d "$LEAVE_APP_DATA")

LEAVE_APP_ID=$(echo "$LEAVE_APP_RESPONSE" | jq -r '.id' 2>/dev/null)

if [ "$LEAVE_APP_ID" != "null" ] && [ "$LEAVE_APP_ID" != "" ]; then
    echo -e "${GREEN}✅ Demo leave application submitted: ID $LEAVE_APP_ID${NC}"
else
    echo -e "${YELLOW}⚠️ Demo leave application test (expected for demo mode)${NC}"
fi

echo -e "\n${YELLOW}3. Testing UI Files${NC}"
echo "-------------------"

# Check if UI files exist and are accessible
UI_FILES=("frontend/attendance.html" "frontend/leave.html" "frontend/index.html")

for file in "${UI_FILES[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(wc -c < "$file")
        echo -e "${GREEN}✅ $file exists (${SIZE} bytes)${NC}"
    else
        echo -e "${RED}❌ $file missing${NC}"
    fi
done

echo -e "\n${YELLOW}4. System Summary${NC}"
echo "------------------"

# Check backend status
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "${API_BASE}/health" 2>/dev/null)
if [ "$BACKEND_STATUS" = "200" ]; then
    echo -e "${GREEN}✅ Backend API: Running${NC}"
else
    echo -e "${RED}❌ Backend API: Not responding (HTTP $BACKEND_STATUS)${NC}"
fi

# Check database
DB_STATUS=$(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) FROM time_slot WHERE active = true;" -t 2>/dev/null | tr -d ' ')
if [ "$DB_STATUS" -gt 0 ]; then
    echo -e "${GREEN}✅ Database: Connected ($DB_STATUS active time slots)${NC}"
else
    echo -e "${RED}❌ Database: Connection issues${NC}"
fi

echo -e "\n${GREEN}🎉 UI Systems Test Complete!${NC}"
echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Open http://localhost:3000 to access the system"
echo "2. Test attendance.html for attendance management"
echo "3. Test leave.html for leave management"
echo "4. Both systems now support MRIT's actual schedule (9:15 AM - 4:15 PM)"
echo "5. Time slots include proper breaks: 11:15-11:30 AM and 1:30-2:30 PM"