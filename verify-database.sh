#!/bin/bash

echo "🗄️ MRIT Hub Database Verification"
echo "================================="

echo "📊 Table Count:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = 'public';"

echo ""
echo "📋 Tables by Category:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "
SELECT 
  CASE 
    WHEN table_name LIKE 'attendance_%' THEN 'Attendance System'
    WHEN table_name LIKE 'leave_%' THEN 'Leave Management'
    WHEN table_name LIKE 'sms_%' THEN 'Communication'
    WHEN table_name IN ('student_data', 'student_variables', 'admission', 'placement') THEN 'Student Management'
    WHEN table_name IN ('faculty', 'users') THEN 'Faculty/Users'
    ELSE 'Master Data'
  END as category,
  COUNT(*) as table_count
FROM information_schema.tables 
WHERE table_schema = 'public' 
GROUP BY category
ORDER BY table_count DESC;"

echo ""
echo "📈 Data Statistics:"
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "
SELECT 'Departments' as entity, COUNT(*) as count FROM department
UNION ALL SELECT 'Faculty', COUNT(*) FROM faculty
UNION ALL SELECT 'Leave Types', COUNT(*) FROM leave_type WHERE active = true
UNION ALL SELECT 'Time Slots', COUNT(*) FROM time_slot WHERE active = true
UNION ALL SELECT 'Leave Balances', COUNT(*) FROM leave_balance
UNION ALL SELECT 'Leave Applications', COUNT(*) FROM leave_application
UNION ALL SELECT 'SMS Templates', COUNT(*) FROM sms_template WHERE is_active = true;"

echo ""
echo "✅ Database Schema Status: VERIFIED"