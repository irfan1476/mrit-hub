-- MRIT Hub Seed Data
-- Initial data for master tables

-- Schemes
INSERT INTO scheme(scheme_yr) VALUES (2015), (2017), (2018), (2021), (2022);

-- Course Categories
INSERT INTO coursecat(category) VALUES ('BSC'), ('ESC'), ('HSMC'), ('PCC'), ('OEC');

-- Departments
INSERT INTO department(code, dept_name) VALUES
('CHE', 'Chemistry'),
('PHY', 'Physics'),
('MAT', 'Mathematics'),
('HSM', 'Humanities'),
('CV', 'Civil Engineering'),
('CSE', 'Computer Science & Engineering'),
('ECE', 'Electronics & Communications Engineering'),
('ME', 'Mechanical Engineering'),
('EEE', 'Electrical & Electronics Engineering'),
('ISE', 'Information Science & Engineering');

-- Semesters
INSERT INTO semester(semester) VALUES (1), (2), (3), (4), (5), (6), (7), (8);

-- Sections
INSERT INTO section(name) VALUES ('A'), ('B'), ('C'), ('D');

-- Gender
INSERT INTO gender(gender) VALUES ('Male'), ('Female'), ('Other');

-- Reservation Categories
INSERT INTO reservation(category) VALUES ('GM'), ('OBC'), ('SC'), ('ST'), ('CAT-1');

-- Admission Categories
INSERT INTO admission(category) VALUES ('CET'), ('COMED-K'), ('Management'), ('SNQ');

-- Entry Types
INSERT INTO entry(category) VALUES ('Regular'), ('Lateral');

-- Academic Years
INSERT INTO academic_year(yr) VALUES
('2015-16'), ('2016-17'), ('2017-18'), ('2018-19'), ('2019-20'),
('2020-21'), ('2021-22'), ('2022-23'), ('2023-24'), ('2024-25');

-- Financial Years
INSERT INTO financial_year(yr) VALUES
('2015-16'), ('2016-17'), ('2017-18'), ('2018-19'), ('2019-20'),
('2020-21'), ('2021-22'), ('2022-23'), ('2023-24'), ('2024-25');

-- Exam Types
INSERT INTO exam_type(ex_type) VALUES ('Regular'), ('Arrears'), ('Supplementary');

-- Graduation Years
INSERT INTO grad_year(year) VALUES
(2020), (2021), (2022), (2023), (2024), (2025), (2026), (2027), (2028);

-- Batches
INSERT INTO batch(year) VALUES
(2018), (2019), (2020), (2021), (2022), (2023), (2024);

-- Sample SMS Template
INSERT INTO sms_template(name, template_id, body, active) VALUES
('Daily Absent Alert', 'DLT_TEMPLATE_001', 'Dear Parent, Your ward {#var1#} was absent on {#var2#} for {#var3#}. Total attendance: {#var4#}%. MRIT', TRUE);

-- Sample Faculty (for testing)
INSERT INTO faculty(faculty_name, short_name, email_org, active) VALUES
('System Admin', 'ADMIN', 'admin@mrit.ac.in', TRUE),
('Test Faculty', 'TF', 'test.faculty@mrit.ac.in', TRUE);
