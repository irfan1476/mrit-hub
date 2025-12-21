#!/usr/bin/env python3
"""
MRIT Data Import Script
Imports all data from mrit.sql dump into the new schema with proper transformations
"""

import re
import psycopg2
from psycopg2.extras import execute_batch

# Database connection
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="mrit_hub",
    user="mrit_admin",
    password="mrit_secure_pass_2024"
)

def parse_copy_data(filename, table_name):
    """Extract COPY data for a specific table from SQL dump"""
    with open(filename, 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    # Find COPY statement for the table
    pattern = rf'COPY public\.{table_name} \([^)]+\) FROM stdin;(.*?)\\\\.'
    match = re.search(pattern, content, re.DOTALL)
    
    if not match:
        print(f"❌ No data found for table: {table_name}")
        return []
    
    data_block = match.group(1).strip()
    rows = []
    
    for line in data_block.split('\n'):
        if line.strip() and not line.startswith('--'):
            # Split by tab and handle NULL values
            fields = line.split('\t')
            fields = [None if f == '\\N' else f for f in fields]
            rows.append(fields)
    
    return rows

def import_students(cursor):
    """Import all student data"""
    print("📊 Importing student data...")
    
    rows = parse_copy_data('database/mrit.sql', 'student_data')
    print(f"   Found {len(rows)} student records")
    
    if not rows:
        return
    
    # Transform and insert
    insert_query = """
    INSERT INTO student_data (
        usn, student_name, branch_id, phone, email, dob,
        father_name, father_phone, mother_name, alt_phone,
        parent_primary_phone, address, blood_group,
        gender_id, batch_id, entry_id, res_cat_id, adm_cat_id
    ) VALUES (
        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
    ) ON CONFLICT (usn) DO UPDATE SET
        student_name = EXCLUDED.student_name,
        phone = EXCLUDED.phone,
        email = EXCLUDED.email
    """
    
    student_vars_query = """
    INSERT INTO student_variables (
        usn, grad_year_id, scheme_id, semester_id, section_id,
        mentor_id, year_back, active
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT (usn) DO UPDATE SET
        semester_id = EXCLUDED.semester_id,
        section_id = EXCLUDED.section_id,
        active = EXCLUDED.active
    """
    
    # Section name to ID mapping
    section_map = {'A': 1, 'B': 2, 'C': 3, 'D': 4}
    
    student_data = []
    student_vars = []
    
    for row in rows:
        if len(row) < 34 or not row[1]:  # usn is at index 1
            continue
            
        usn = row[1]
        student_name = row[2]
        branch_id = int(row[3]) if row[3] else None
        phone = row[4]
        email = row[6] if row[6] else row[5]  # email_org or email
        dob = row[7]
        father_name = row[9]
        father_phone = row[10]
        mother_name = row[11]
        alt_phone = row[12]
        parent_phone = father_phone if father_phone else alt_phone
        address = row[13]
        blood_group = row[14]
        gender_id = int(row[15]) if row[15] else None
        batch_id = int(row[16]) if row[16] else None
        entry_id = int(row[17]) if row[17] else None
        res_cat_id = int(row[18]) if row[18] else None
        adm_cat_id = int(row[19]) if row[19] else None
        
        student_data.append((
            usn, student_name, branch_id, phone, email, dob,
            father_name, father_phone, mother_name, alt_phone,
            parent_phone, address, blood_group,
            gender_id, batch_id, entry_id, res_cat_id, adm_cat_id
        ))
        
        # Student variables
        grad_year_id = int(row[25]) if row[25] else None
        scheme_id = int(row[26]) if row[26] else None
        semester_id = int(row[27]) if row[27] else None
        sec_name = row[33] if row[33] else None
        section_id = section_map.get(sec_name) if sec_name else None
        mentor_id = int(row[29]) if row[29] else None
        year_back = row[23] == 't' if row[23] else False
        active = row[24] == 't' if row[24] else True
        
        student_vars.append((
            usn, grad_year_id, scheme_id, semester_id, section_id,
            mentor_id, year_back, active
        ))
    
    # Execute batch inserts
    execute_batch(cursor, insert_query, student_data, page_size=100)
    execute_batch(cursor, student_vars_query, student_vars, page_size=100)
    
    print(f"   ✅ Imported {len(student_data)} students")

def import_faculty(cursor):
    """Import faculty/employee data"""
    print("👨‍🏫 Importing faculty data...")
    
    rows = parse_copy_data('database/mrit.sql', 'employee_data')
    print(f"   Found {len(rows)} employee records")
    
    if not rows:
        return
    
    insert_query = """
    INSERT INTO faculty (
        faculty_name, phone, short_name, email_org, email_personal,
        dob, address, qualification, join_date, active
    ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT DO NOTHING
    """
    
    faculty_data = []
    
    for row in rows:
        if len(row) < 10:
            continue
        
        # Map employee_data fields to faculty fields
        faculty_data.append((
            row[1] if len(row) > 1 else None,  # name
            row[2] if len(row) > 2 else None,  # phone
            row[3] if len(row) > 3 else None,  # short_name
            row[4] if len(row) > 4 else None,  # email_org
            row[5] if len(row) > 5 else None,  # email_personal
            row[6] if len(row) > 6 else None,  # dob
            row[7] if len(row) > 7 else None,  # address
            row[8] if len(row) > 8 else None,  # qualification
            row[9] if len(row) > 9 else None,  # join_date
            True  # active
        ))
    
    execute_batch(cursor, insert_query, faculty_data, page_size=100)
    print(f"   ✅ Imported {len(faculty_data)} faculty members")

def import_courses(cursor):
    """Import course data"""
    print("📚 Importing course data...")
    
    rows = parse_copy_data('database/mrit.sql', 'course')
    print(f"   Found {len(rows)} course records")
    
    if not rows:
        return
    
    insert_query = """
    INSERT INTO course (
        code, course_name, credit, scheme_id, semester_id, dept_id, course_cat_id
    ) VALUES (%s, %s, %s, %s, %s, %s, %s)
    ON CONFLICT (code) DO UPDATE SET
        course_name = EXCLUDED.course_name,
        credit = EXCLUDED.credit
    """
    
    course_data = []
    
    for row in rows:
        if len(row) < 7:
            continue
        
        course_data.append((
            row[1],  # code
            row[2],  # course_name
            int(row[3]) if row[3] else None,  # credit
            int(row[4]) if row[4] else None,  # scheme_id
            int(row[5]) if row[5] else None,  # semester_id
            int(row[6]) if row[6] else None,  # dept_id
            int(row[7]) if row[7] and len(row) > 7 else None  # course_cat_id
        ))
    
    execute_batch(cursor, insert_query, course_data, page_size=100)
    print(f"   ✅ Imported {len(course_data)} courses")

def main():
    print("🚀 MRIT Data Import - Full Migration")
    print("=" * 50)
    
    try:
        cursor = conn.cursor()
        
        # Disable triggers temporarily
        cursor.execute("SET session_replication_role = replica;")
        
        # Import data
        import_students(cursor)
        import_faculty(cursor)
        import_courses(cursor)
        
        # Re-enable triggers
        cursor.execute("SET session_replication_role = DEFAULT;")
        
        # Commit transaction
        conn.commit()
        
        # Show summary
        print("\n📊 Import Summary:")
        cursor.execute("SELECT COUNT(*) FROM student_data")
        print(f"   Students: {cursor.fetchone()[0]}")
        
        cursor.execute("SELECT COUNT(*) FROM faculty")
        print(f"   Faculty: {cursor.fetchone()[0]}")
        
        cursor.execute("SELECT COUNT(*) FROM course")
        print(f"   Courses: {cursor.fetchone()[0]}")
        
        print("\n✅ Data import completed successfully!")
        
    except Exception as e:
        print(f"\n❌ Error during import: {e}")
        conn.rollback()
    finally:
        cursor.close()
        conn.close()

if __name__ == "__main__":
    main()
