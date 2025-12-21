-- Import Timetable and Infrastructure Data from mrit.sql
-- Import room and timetable data for attendance system

-- ============================================================================
-- IMPORT ROOM DATA
-- ============================================================================

-- Import room numbers from infra.room_numbers
INSERT INTO infra.room_number (
    room_number,
    room_type_id,
    floor_id,
    description
)
SELECT 
    rn.room_number,
    CASE 
        WHEN rn.room_type = 1 THEN 1  -- Classroom
        WHEN rn.room_type = 2 THEN 2  -- Laboratory  
        WHEN rn.room_type = 3 THEN 3  -- Seminar Hall
        ELSE 1
    END as room_type_id,
    CASE 
        WHEN rn.floor_id BETWEEN 1 AND 5 THEN rn.floor_id
        ELSE 1
    END as floor_id,
    rn.description
FROM infra.room_numbers rn
WHERE rn.room_number IS NOT NULL
ON CONFLICT DO NOTHING;

-- Import room allotments
INSERT INTO infra.room_allotment (
    room_number_id,
    dept_id,
    room_area,
    remarks
)
SELECT 
    rnum.id as room_number_id,
    CASE 
        WHEN ra.dept_id BETWEEN 1 AND 10 THEN ra.dept_id
        ELSE NULL
    END as dept_id,
    ra.room_area,
    ra.remarks
FROM infra.room_alottment ra
JOIN infra.room_number rnum ON rnum.room_number = ra.room_no
WHERE ra.room_no IS NOT NULL
ON CONFLICT DO NOTHING;

-- ============================================================================
-- IMPORT TIMETABLE DATA
-- ============================================================================

-- Create mapping for existing timetable data
INSERT INTO time_table.timetable (
    academic_year_id,
    semester_id,
    branch_id,
    section_id,
    weekday_id,
    class_period_id,
    course_id,
    faculty_id,
    room_number_id
)
SELECT 
    CASE 
        WHEN tt.aca_yr_id BETWEEN 1 AND 10 THEN tt.aca_yr_id
        ELSE 1
    END as academic_year_id,
    CASE 
        WHEN tt.semester_id BETWEEN 1 AND 8 THEN tt.semester_id
        ELSE 1
    END as semester_id,
    CASE 
        WHEN tt.branch_id BETWEEN 1 AND 10 THEN tt.branch_id
        ELSE 1
    END as branch_id,
    CASE 
        WHEN tt.section_id BETWEEN 1 AND 4 THEN tt.section_id
        ELSE 1
    END as section_id,
    CASE 
        WHEN tt.weekday_id BETWEEN 1 AND 6 THEN tt.weekday_id
        ELSE 1
    END as weekday_id,
    CASE 
        WHEN tt.class_id BETWEEN 1 AND 6 THEN tt.class_id
        ELSE 1
    END as class_period_id,
    c.id as course_id,
    f.id as faculty_id,
    rn.id as room_number_id
FROM time_table.tt_2425 tt
LEFT JOIN course c ON c.course_code = tt.course_code
LEFT JOIN faculty f ON f.employee_id = tt.faculty_id
LEFT JOIN infra.room_number rn ON rn.id = tt.room_number_id
WHERE tt.aca_yr_id IS NOT NULL
    AND tt.semester_id IS NOT NULL
    AND tt.section_id IS NOT NULL
    AND tt.weekday_id IS NOT NULL
    AND tt.class_id IS NOT NULL
ON CONFLICT (academic_year_id, semester_id, section_id, weekday_id, class_period_id) DO NOTHING;

-- ============================================================================
-- IMPORT SUMMARY
-- ============================================================================

SELECT 
    'Room Numbers' as data_type,
    COUNT(*) as imported_count
FROM infra.room_number

UNION ALL

SELECT 
    'Room Allotments' as data_type,
    COUNT(*) as imported_count
FROM infra.room_allotment

UNION ALL

SELECT 
    'Timetable Entries' as data_type,
    COUNT(*) as imported_count
FROM time_table.timetable

UNION ALL

SELECT 
    'Weekdays' as data_type,
    COUNT(*) as imported_count
FROM time_table.weekday

UNION ALL

SELECT 
    'Class Periods' as data_type,
    COUNT(*) as imported_count
FROM time_table.class_period;