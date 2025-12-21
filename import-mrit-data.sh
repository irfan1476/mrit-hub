#!/bin/bash

# MRIT Data Import Setup Script
# This script prepares the mrit.sql data for import into MRIT Hub

set -e

echo "🚀 MRIT Data Import Setup"
echo "========================="

# Check if mrit.sql exists
if [ ! -f "database/mrit.sql" ]; then
    echo "❌ Error: database/mrit.sql not found"
    echo "Please ensure mrit.sql is in the database/ directory"
    exit 1
fi

echo "📋 Step 1: Creating external schema for mrit.sql data..."

# Connect to database and create external schema
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub << 'EOF'
-- Create external schema for mrit.sql data
DROP SCHEMA IF EXISTS mrit_external CASCADE;
CREATE SCHEMA mrit_external;
EOF

echo "📥 Step 2: Importing mrit.sql data into external schema..."

# Import mrit.sql into external schema
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub << 'EOF'
-- Set search path to external schema
SET search_path TO mrit_external, public;
EOF

# Import the mrit.sql file (modify schema references)
sed 's/public\./mrit_external\./g' database/mrit.sql | \
sed 's/CREATE TABLE /CREATE TABLE mrit_external\./g' | \
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub

echo "🔧 Step 3: Running schema enhancements..."

# Apply schema enhancements
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub -f /docker-entrypoint-initdb.d/migrations/011-schema-enhancements-for-import.sql

echo "📊 Step 4: Running data import..."

# Run the data import script
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub -f /docker-entrypoint-initdb.d/import-mrit-data.sql

echo "✅ Data import completed!"
echo ""
echo "📈 Import Summary:"
docker exec -i mrit-postgres psql -U mrit_admin -d mrit_hub -c "
SELECT 
    'Faculty' as table_name,
    COUNT(*) as imported_count
FROM faculty
WHERE employee_id IS NOT NULL

UNION ALL

SELECT 
    'Students' as table_name,
    COUNT(*) as imported_count
FROM student_data

UNION ALL

SELECT 
    'Courses' as table_name,
    COUNT(*) as imported_count
FROM course

UNION ALL

SELECT 
    'Departments' as table_name,
    COUNT(*) as imported_count
FROM department;
"

echo ""
echo "🎉 MRIT data import setup complete!"
echo "Your MRIT Hub now contains real production data from mrit.sql"