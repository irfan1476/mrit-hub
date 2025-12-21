-- Extract more student data from mrit.sql and insert into our database
-- This script adds more CSE students for testing

-- Add more CSE students based on the data found in mrit.sql
INSERT INTO student_data (usn, student_name, branch_id, phone, email, parent_primary_phone) VALUES
('4MU22CS001', 'Student One', 6, '9876543220', 'student1@example.com', '9876543221'),
('4MU22CS002', 'Adhika G', 6, '8660081604', 'adhikagadhikag05@gmail.com', '9876543222'),
('4MU22CS003', 'Akash H M', 6, '9353235911', 'akash665016@gmail.com', '9980136648'),
('4MU22CS006', 'Bhuvana D V', 6, '9731892627', 'bhuvanadv08@gmail.com', '9876543223'),
('4MU22CS007', 'Bhuvana K', 6, '8310649296', 'bk0173915@gmail.com', '9876543224'),
('4MU22CS008', 'Bi Bi Fazila', 6, '9876543225', 'fazila@example.com', '9876543226'),
('4MU22CS009', 'Student Nine', 6, '9876543227', 'student9@example.com', '9876543228'),
('4MU22CS010', 'Chandana C N', 6, '8660879137', 'cchandana6353@gmail.com', '9731400985'),
('4MU22CS011', 'Student Eleven', 6, '9876543229', 'student11@example.com', '9876543230'),
('4MU22CS012', 'Student Twelve', 6, '9876543231', 'student12@example.com', '9876543232'),
('4MU22CS015', 'Deemanth Gowda K P', 6, '7483878390', 'deemanthgowdakp0007@gmail.com', '7760037691'),
('4MU22CS024', 'Hemanth C', 6, '9876543233', 'hemanth@example.com', '9876543234'),
('4MU22CS025', 'Hemanth Kumar L', 6, '9876543235', 'hemanthkumar@example.com', '9876543236'),
('4MU22CS038', 'Lavanya P S', 6, '9876543237', 'lavanya@example.com', '9876543238'),
('4MU22CS040', 'Likith P', 6, '9876543239', 'likith@example.com', '9876543240'),
('4MU22CS042', 'M Apoorva', 6, '9019470061', 'mapoorva382@gmail.com', '9876543241'),
('4MU22CS047', 'Monisha B P', 6, '7204758782', 'Monishamoni0267731@gmail.com', '9880561916'),
('4MU22CS052', 'Nikhitha P', 6, '9876543242', 'nikhitha@example.com', '9876543243'),
('4MU22CS065', 'Pratheeksha S R', 6, '9876543244', 'pratheeksha@example.com', '9876543245'),
('4MU22CS101', 'Yuvasri Jagan J', 6, '9448569696', 'yuvasrijagan0406@gmail.com', '8217370008');

-- Add student variables for all these students (3rd semester, section A)
INSERT INTO student_variables (usn, semester_id, section_id, active) VALUES
('4MU22CS001', 3, 1, TRUE),
('4MU22CS002', 3, 1, TRUE),
('4MU22CS003', 3, 1, TRUE),
('4MU22CS006', 3, 1, TRUE),
('4MU22CS007', 3, 1, TRUE),
('4MU22CS008', 3, 1, TRUE),
('4MU22CS009', 3, 1, TRUE),
('4MU22CS010', 3, 1, TRUE),
('4MU22CS011', 3, 1, TRUE),
('4MU22CS012', 3, 1, TRUE),
('4MU22CS015', 3, 1, TRUE),
('4MU22CS024', 3, 1, TRUE),
('4MU22CS025', 3, 1, TRUE),
('4MU22CS038', 3, 1, TRUE),
('4MU22CS040', 3, 1, TRUE),
('4MU22CS042', 3, 1, TRUE),
('4MU22CS047', 3, 1, TRUE),
('4MU22CS052', 3, 1, TRUE),
('4MU22CS065', 3, 1, TRUE),
('4MU22CS101', 3, 1, TRUE);

-- Add some students to section B as well
INSERT INTO student_data (usn, student_name, branch_id, phone, email, parent_primary_phone) VALUES
('4MU22CS051', 'Nikhil B A', 6, '9876543246', 'nikhil@example.com', '9876543247'),
('4MU22CS053', 'Nisarga A', 6, '9876543248', 'nisarga@example.com', '9876543249'),
('4MU22CS054', 'Nisarga H', 6, '9876543250', 'nisargah@example.com', '9876543251'),
('4MU22CS061', 'Student B1', 6, '9876543252', 'studentb1@example.com', '9876543253'),
('4MU22CS072', 'Ravi Kumar N Rao', 6, '9876543254', 'ravi@example.com', '9876543255');

INSERT INTO student_variables (usn, semester_id, section_id, active) VALUES
('4MU22CS051', 3, 2, TRUE),
('4MU22CS053', 3, 2, TRUE),
('4MU22CS054', 3, 2, TRUE),
('4MU22CS061', 3, 2, TRUE),
('4MU22CS072', 3, 2, TRUE);

-- Add some faculty members
INSERT INTO faculty (faculty_name, short_name, email_org, active) VALUES
('Dr. Rajesh Kumar', 'RK', 'rajesh.kumar@mrit.ac.in', TRUE),
('Prof. Sunita Sharma', 'SS', 'sunita.sharma@mrit.ac.in', TRUE),
('Dr. Amit Patel', 'AP', 'amit.patel@mrit.ac.in', TRUE),
('Prof. Priya Nair', 'PN', 'priya.nair@mrit.ac.in', TRUE),
('Dr. Vikram Singh', 'VS', 'vikram.singh@mrit.ac.in', TRUE);