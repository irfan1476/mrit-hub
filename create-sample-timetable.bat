@echo off
REM Create sample timetable data for testing

echo ========================================
echo 📅 Creating Sample Timetable Data
echo ========================================
echo.

echo Creating course offerings and timetable for testing...

docker exec mrit-postgres psql -U mrit_admin -d mrit_hub << 'EOSQL'

-- Get current academic year
DO $$
DECLARE
    current_ay_id INT;
    faculty_ids INT[];
    course_ids INT[];
    section_ids INT[];
BEGIN
    -- Get IDs
    SELECT id INTO current_ay_id FROM academic_year WHERE year = '2024-25' LIMIT 1;
    SELECT ARRAY_AGG(id) INTO faculty_ids FROM faculty WHERE active = true LIMIT 5;
    SELECT ARRAY_AGG(id) INTO course_ids FROM course LIMIT 10;
    SELECT ARRAY_AGG(id) INTO section_ids FROM section LIMIT 4;

    -- Create course offerings (5 faculty x 2 courses each x 1 section)
    FOR i IN 1..5 LOOP
        FOR j IN 1..2 LOOP
            INSERT INTO course_offering (course_id, faculty_id, section_id, academic_year_id, active)
            VALUES (
                course_ids[j],
                faculty_ids[i],
                section_ids[1],  -- Section A
                current_ay_id,
                true
            ) ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;

    -- Create timetable entries (Monday to Friday, 6 periods per day)
    -- Day 1 (Monday) - 6 periods
    INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active)
    SELECT co.id, ts.id, 1, 'Room ' || (100 + ts.id), true
    FROM course_offering co
    CROSS JOIN (SELECT id FROM time_slot WHERE id BETWEEN 1 AND 6) ts
    WHERE co.id IN (SELECT id FROM course_offering LIMIT 6)
    ON CONFLICT DO NOTHING;

    -- Day 2 (Tuesday) - 6 periods
    INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active)
    SELECT co.id, ts.id, 2, 'Room ' || (200 + ts.id), true
    FROM course_offering co
    CROSS JOIN (SELECT id FROM time_slot WHERE id BETWEEN 1 AND 6) ts
    WHERE co.id IN (SELECT id FROM course_offering OFFSET 1 LIMIT 6)
    ON CONFLICT DO NOTHING;

    -- Day 3 (Wednesday) - 6 periods
    INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active)
    SELECT co.id, ts.id, 3, 'Room ' || (300 + ts.id), true
    FROM course_offering co
    CROSS JOIN (SELECT id FROM time_slot WHERE id BETWEEN 1 AND 6) ts
    WHERE co.id IN (SELECT id FROM course_offering OFFSET 2 LIMIT 6)
    ON CONFLICT DO NOTHING;

    -- Day 4 (Thursday) - 6 periods
    INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active)
    SELECT co.id, ts.id, 4, 'Room ' || (400 + ts.id), true
    FROM course_offering co
    CROSS JOIN (SELECT id FROM time_slot WHERE id BETWEEN 1 AND 6) ts
    WHERE co.id IN (SELECT id FROM course_offering OFFSET 3 LIMIT 6)
    ON CONFLICT DO NOTHING;

    -- Day 5 (Friday) - 6 periods
    INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active)
    SELECT co.id, ts.id, 5, 'Room ' || (500 + ts.id), true
    FROM course_offering co
    CROSS JOIN (SELECT id FROM time_slot WHERE id BETWEEN 1 AND 6) ts
    WHERE co.id IN (SELECT id FROM course_offering OFFSET 4 LIMIT 6)
    ON CONFLICT DO NOTHING;

    RAISE NOTICE 'Sample timetable data created successfully';
END $$;

EOSQL

echo.
echo 📊 Verifying created data...
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT 'Course Offerings' as entity, COUNT(*) FROM course_offering UNION ALL SELECT 'Timetable Entries', COUNT(*) FROM timetable;"

echo.
echo Sample timetable for today:
docker exec mrit-postgres psql -U mrit_admin -d mrit_hub -c "SELECT t.id, ts.slot_name, ts.start_time, ts.end_time, c.course_name, f.faculty_name, t.room_number FROM timetable t JOIN course_offering co ON t.course_offering_id = co.id JOIN course c ON co.course_id = c.id JOIN faculty f ON co.faculty_id = f.id JOIN time_slot ts ON t.time_slot_id = ts.id WHERE t.day_of_week = EXTRACT(ISODOW FROM CURRENT_DATE) AND t.active = true ORDER BY ts.start_time LIMIT 10;"

echo.
echo ✅ Sample timetable created!
echo.

pause
