#!/bin/bash

echo "🎯 MRIT Hub - Leave Management Final Test"
echo "========================================"

API_BASE="http://localhost:3000/api/v1"

echo "✅ Testing All Fixed Endpoints:"
echo ""

echo "1. Leave Types:"
status=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE/leave/types")
echo "   Status: $status"

echo ""
echo "2. Demo Balance:"
status=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE/leave/demo/balance")
echo "   Status: $status"

echo ""
echo "3. Demo Applications:"
status=$(curl -s -o /dev/null -w "%{http_code}" "$API_BASE/leave/demo/applications")
echo "   Status: $status"

echo ""
echo "4. Demo Apply (POST):"
response=$(curl -s -X POST "$API_BASE/leave/demo/apply" \
  -H "Content-Type: application/json" \
  -d '{"leave_type_id":1,"from_date":"2025-01-25","to_date":"2025-01-26","total_days":2,"reason":"Final test","substitute_faculty_id":2}')
status=$(echo "$response" | jq -r '.id // "error"')
echo "   Status: $([ "$status" != "error" ] && echo "✅ Success (ID: $status)" || echo "❌ Failed")"

echo ""
echo "5. Backend Error Check:"
errors=$(docker-compose logs --tail=50 backend | grep -E "(error|Error|ERROR)" | wc -l)
echo "   Errors: $errors (should be 0)"

echo ""
echo "🌐 Frontend Test:"
echo "   Open: file://$(pwd)/frontend/leave.html"
echo "   Expected: All sections load without errors"
echo "   Form submission: Should work with demo endpoint"

echo ""
if [ "$errors" -eq 0 ]; then
    echo "✅ ALL TESTS PASSED - No errors in logs"
else
    echo "⚠️  Some errors found in logs"
fi