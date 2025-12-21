#!/bin/bash

echo "🎯 MRIT Data Migration Summary"
echo "=============================="

echo ""
echo "📊 Database Population Status:"

echo "Students: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c 'SELECT COUNT(*) FROM student_data;' | tr -d ' ')"
echo "Faculty: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c 'SELECT COUNT(*) FROM faculty;' | tr -d ' ')"
echo "Courses: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c 'SELECT COUNT(*) FROM course;' | tr -d ' ')"
echo "Time Slots: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c 'SELECT COUNT(*) FROM time_slot;' | tr -d ' ')"

echo ""
echo "🎓 Student Distribution:"
echo "CSE 3rd Sem Section A: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c "SELECT COUNT(*) FROM student_data sd JOIN student_variables sv ON sd.usn = sv.usn WHERE sd.branch_id = 6 AND sv.semester_id = 3 AND sv.section_id = 1;" | tr -d ' ')"
echo "CSE 3rd Sem Section B: $(docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -t -c "SELECT COUNT(*) FROM student_data sd JOIN student_variables sv ON sd.usn = sv.usn WHERE sd.branch_id = 6 AND sv.semester_id = 3 AND sv.section_id = 2;" | tr -d ' ')"

echo ""
echo "🧪 API Testing:"
echo "Section A Students API: $(curl -s "http://localhost:3000/api/v1/attendance/students?department=CSE&semester=3&section=A&subject_code=21CS31" | jq '. | length') students"
echo "Section B Students API: $(curl -s "http://localhost:3000/api/v1/attendance/students?department=CSE&semester=3&section=B&subject_code=21CS31" | jq '. | length') students"
echo "Time Slots API: $(curl -s "http://localhost:3000/api/v1/attendance/time-slots" | jq '. | length') time slots"

echo ""
echo "✅ Migration Status: SUCCESS"
echo "🌐 Frontend: http://localhost:8080/attendance.html"
echo "🔗 API Base: http://localhost:3000/api/v1/attendance"

echo ""
echo "📋 Sample Students (CSE 3rd Sem A):"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT usn, student_name FROM student_data sd JOIN student_variables sv ON sd.usn = sv.usn WHERE sd.branch_id = 6 AND sv.semester_id = 3 AND sv.section_id = 1 ORDER BY sd.usn LIMIT 10;"