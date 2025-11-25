# MRIT Hub Database ERD

Complete Entity Relationship Diagram for all 27 tables.

## Table Summary

| Category | Tables | Count |
|----------|--------|-------|
| Master/Reference | grad_year, gender, reservation, admission, entry, batch, department, scheme, coursecat, semester, academic_year, financial_year, exam_type, section | 14 |
| Faculty & Staff | faculty | 1 |
| Student Core | student_data, student_variables, placement | 3 |
| Academic Structure | course, course_offering | 2 |
| Attendance | attendance_session, attendance_record, attendance_log, attendance_summary | 4 |
| Notifications | sms_template, sms_log, notification_preference | 3 |
| **TOTAL** | | **27** |

## Key Relationships

### Student Identity Flow
```
student_data (USN, personal info)
    ↓ 1:1
student_variables (academic state: semester, section, mentor)
    ↓ 1:1
placement (SSLC/PUC marks, skills, backlogs)
```

### Attendance Flow
```
course (subject definition)
    ↓ 1:N
course_offering (faculty + section + academic year)
    ↓ 1:N
attendance_session (one class instance)
    ↓ 1:N
attendance_record (P/A per student)
    ↓ 1:N
attendance_log (audit trail)
```

### SMS Notification Flow
```
attendance_record (status = 'A')
    ↓ triggers
sms_log (queued SMS)
    ↓ uses
sms_template (DLT template)
    ↓ sends to
student_data.parent_primary_phone
```

## New Tables (vs Original Schema)

### 1. section
- **Purpose**: Represent class sections (A, B, C, D)
- **Links**: student_variables, course_offering
- **Why**: Attendance is section-specific

### 2. course_offering
- **Purpose**: Link course + faculty + section + academic year
- **Links**: course, faculty, section, academic_year
- **Why**: Same course taught by different faculty to different sections

### 3. attendance_session
- **Purpose**: One class instance
- **Links**: course_offering, faculty (created_by)
- **Why**: Implements 36-hour edit window, tracks each class

### 4. attendance_record
- **Purpose**: Student attendance per session (P/A/L/OD/M)
- **Links**: attendance_session, student_data, faculty (marked_by)
- **Why**: Raw attendance data for calculations

### 5. attendance_log
- **Purpose**: Audit trail for attendance changes
- **Links**: attendance_session, student_data, faculty (changed_by)
- **Why**: Compliance, dispute resolution

### 6. attendance_summary
- **Purpose**: Pre-computed attendance percentages
- **Links**: student_data, course_offering
- **Why**: Performance optimization for dashboards

### 7. sms_template
- **Purpose**: DLT-compliant SMS templates
- **Why**: Required for SMS gateway integration

### 8. sms_log
- **Purpose**: Track every SMS sent
- **Links**: student_data, sms_template
- **Why**: Debugging, compliance, proof of communication

### 9. notification_preference
- **Purpose**: Per-student notification settings
- **Links**: student_data
- **Why**: Opt-out capability, future-proofing

## Modified Tables

### student_data
**Added columns:**
- `parent_primary_phone` VARCHAR(15) - Canonical SMS target
- `profile_photo_path` VARCHAR(255) - Local file path
- `phone_verified` BOOLEAN - OTP verification status

### student_variables
**Added column:**
- `section_id` INTEGER - Links to section table

### faculty
**Added column:**
- `profile_photo_path` VARCHAR(255) - Local file path

## Indexes

All foreign keys are indexed for performance.

**Additional indexes:**
- student_data: usn, branch_id, batch_id
- student_variables: usn, section_id, mentor_id, active
- course: scheme_id, semester_id, dept_id
- course_offering: course_id, faculty_id, section_id, active
- attendance_session: course_offering_id, session_date, status
- attendance_record: session_id, student_id, status
- attendance_log: session_id, student_id
- attendance_summary: student_id, course_offering_id
- sms_log: student_id, status, sent_at

## Triggers

**Auto-update timestamps:**
- faculty.updated_at
- student_data.updated_at
- student_variables.updated_at
- course_offering.updated_at

## File Storage

Profile photos stored at:
```
/mnt/mrit_data/profile_photos/
├── students/
│   └── {USN}_{timestamp}.jpg
└── faculty/
    └── {FAC_ID}_{timestamp}.jpg
```

Database stores path, not URL:
- `students/2021CS001_1678888888.jpg`
- `faculty/FAC001_1678890000.jpg`

## Access Patterns

### Common Queries

**1. Get student attendance for a course:**
```sql
SELECT ar.status, COUNT(*) 
FROM attendance_record ar
JOIN attendance_session asess ON ar.session_id = asess.id
JOIN course_offering co ON asess.course_offering_id = co.id
WHERE ar.student_id = ? AND co.id = ?
GROUP BY ar.status;
```

**2. Get defaulters (< 75%):**
```sql
SELECT sd.usn, sd.student_name, 
       (asumm.present_sessions::float / asumm.total_sessions * 100) as percentage
FROM attendance_summary asumm
JOIN student_data sd ON asumm.student_id = sd.id
WHERE (asumm.present_sessions::float / asumm.total_sessions * 100) < 75;
```

**3. Get students in a section:**
```sql
SELECT sd.* 
FROM student_data sd
JOIN student_variables sv ON sd.usn = sv.usn
WHERE sv.section_id = ? AND sv.semester_id = ? AND sv.active = TRUE;
```

## Data Integrity

**Constraints:**
- All foreign keys with proper ON DELETE CASCADE/RESTRICT
- CHECK constraints on status fields
- UNIQUE constraints on natural keys (USN, email, phone)
- NOT NULL on critical fields

**Referential Integrity:**
- student_variables.usn → student_data.usn (1:1)
- placement.usn → student_data.usn (1:1)
- All other relationships properly enforced

---

For visual ERD, see: [Complete ERD in previous conversation]
