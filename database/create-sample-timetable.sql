-- Create sample timetable data for testing

DO $$
DECLARE
    current_ay_id INT;
    faculty_ids INT[];
    course_ids INT[];
    section_id INT;
    co_id INT;
BEGIN
    -- Get current academic year
    SELECT id INTO current_ay_id FROM academic_year WHERE yr = '2024-25' LIMIT 1;
    
    -- Get first section (A)
    SELECT id INTO section_id FROM section WHERE name = 'A' LIMIT 1;
    
    -- Get faculty and course IDs
    SELECT ARRAY_AGG(id) INTO faculty_ids FROM (SELECT id FROM faculty WHERE active = true LIMIT 5) f;
    SELECT ARRAY_AGG(id) INTO course_ids FROM (SELECT id FROM course LIMIT 10) c;

    -- Create course offerings (5 faculty x 2 courses each)
    FOR i IN 1..LEAST(5, array_length(faculty_ids, 1)) LOOP
        FOR j IN 1..LEAST(2, array_length(course_ids, 1)) LOOP
            INSERT INTO course_offering (course_id, faculty_id, section_id, academic_year_id, active)
            VALUES (
                course_ids[j],
                faculty_ids[i],
                section_id,
                current_ay_id,
                true
            ) ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;

    -- Create timetable entries for Monday (day 1) - 6 periods
    FOR co_id IN (SELECT id FROM course_offering LIMIT 6) LOOP
        FOR slot IN 1..6 LOOP
            INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active)
            VALUES (co_id, slot, 1, 'Room ' || (100 + slot), true)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;

    -- Create timetable entries for Thursday (day 4) - 6 periods
    FOR co_id IN (SELECT id FROM course_offering OFFSET 1 LIMIT 6) LOOP
        FOR slot IN 1..6 LOOP
            INSERT INTO timetable (course_offering_id, time_slot_id, day_of_week, room_number, active)
            VALUES (co_id, slot, 4, 'Room ' || (400 + slot), true)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END LOOP;

    RAISE NOTICE 'Sample timetable data created successfully';
END $$;

SELECT 'Data created' as status;
