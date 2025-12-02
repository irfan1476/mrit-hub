-- Update time slots to match MRIT's actual schedule
-- Periods: 9:15 AM to 4:15 PM with breaks at 11:15-11:30 AM and 1:30-2:30 PM

-- Disable existing time slots first
UPDATE time_slot SET active = false;

-- Update existing slots with MRIT schedule
UPDATE time_slot SET 
    slot_name = 'Period 1', 
    start_time = '09:15:00', 
    end_time = '10:15:00', 
    duration_hours = 1, 
    slot_type = 'THEORY', 
    active = true 
WHERE id = 1;

UPDATE time_slot SET 
    slot_name = 'Period 2', 
    start_time = '10:15:00', 
    end_time = '11:15:00', 
    duration_hours = 1, 
    slot_type = 'THEORY', 
    active = true 
WHERE id = 2;

UPDATE time_slot SET 
    slot_name = 'Period 3', 
    start_time = '11:30:00', 
    end_time = '12:30:00', 
    duration_hours = 1, 
    slot_type = 'THEORY', 
    active = true 
WHERE id = 3;

UPDATE time_slot SET 
    slot_name = 'Period 4', 
    start_time = '12:30:00', 
    end_time = '13:30:00', 
    duration_hours = 1, 
    slot_type = 'THEORY', 
    active = true 
WHERE id = 4;

UPDATE time_slot SET 
    slot_name = 'Period 5', 
    start_time = '14:30:00', 
    end_time = '15:30:00', 
    duration_hours = 1, 
    slot_type = 'THEORY', 
    active = true 
WHERE id = 5;

UPDATE time_slot SET 
    slot_name = 'Period 6', 
    start_time = '15:30:00', 
    end_time = '16:15:00', 
    duration_hours = 0.75, 
    slot_type = 'THEORY', 
    active = true 
WHERE id = 6;

UPDATE time_slot SET 
    slot_name = 'MRIT Hour', 
    start_time = '12:30:00', 
    end_time = '13:30:00', 
    duration_hours = 1, 
    slot_type = 'THEORY', 
    active = true 
WHERE id = 8;

-- Insert additional MRIT time slots
INSERT INTO time_slot (slot_name, start_time, end_time, duration_hours, slot_type, active, created_at) VALUES
-- Lab Sessions (3-hour blocks)
('Lab Session A (Morning)', '09:15:00', '12:15:00', 3, 'LAB', true, NOW()),
('Lab Session B (Afternoon)', '14:30:00', '17:30:00', 3, 'LAB', true, NOW()),

-- Extended Lab Sessions (2-hour blocks)
('Lab Session C (Morning Extended)', '09:15:00', '11:15:00', 2, 'LAB', true, NOW()),
('Lab Session D (Afternoon Extended)', '14:30:00', '16:30:00', 2, 'LAB', true, NOW()),

-- Tutorial Sessions
('Tutorial A', '11:30:00', '12:30:00', 1, 'TUTORIAL', true, NOW()),
('Tutorial B', '15:30:00', '16:30:00', 1, 'TUTORIAL', true, NOW()),

-- Special Sessions
('Extra Class (Early Morning)', '08:15:00', '09:15:00', 1, 'THEORY', true, NOW()),
('Extra Class (Late Evening)', '16:15:00', '17:15:00', 1, 'THEORY', true, NOW());

-- Reset sequence
SELECT setval('time_slot_id_seq', (SELECT MAX(id) FROM time_slot));

-- Verify updated time slots
SELECT id, slot_name, start_time, end_time, duration_hours, slot_type, active 
FROM time_slot 
WHERE active = true 
ORDER BY start_time;