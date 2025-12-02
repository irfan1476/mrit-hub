#!/bin/bash

echo "🧪 Testing MRIT Hub Attendance System"
echo "======================================"

# Test 1: Get time slots
echo "1. Testing time slots endpoint..."
curl -s http://localhost:3000/api/v1/attendance/time-slots | jq -r '.[] | "\(.slot_name) - \(.duration_hours)h \(.slot_type)"' | head -5

echo ""

# Test 2: Get students
echo "2. Testing students endpoint..."
curl -s "http://localhost:3000/api/v1/attendance/students?department=CSE&semester=3&section=A&subject_code=21CS31" | jq -r '.[] | "\(.roll_no) - \(.name)"'

echo ""

# Test 3: Check database counts
echo "3. Database verification..."
echo "Time slots: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c 'SELECT COUNT(*) FROM time_slot;' | tr -d ' ')"
echo "Students: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c 'SELECT COUNT(*) FROM student_data;' | tr -d ' ')"
echo "Courses: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c 'SELECT COUNT(*) FROM course;' | tr -d ' ')"

echo ""
echo "✅ All tests completed!"
echo "🌐 Frontend: http://localhost/attendance.html"
echo "🔗 API Base: http://localhost:3000/api/v1/attendance"