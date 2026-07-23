begin;

-- Stable synthetic users used only for local/dev/test environments.
-- All five accounts use the same pre-generated bcrypt hash. The corresponding
-- synthetic login password is documented in docs/database/database-setup.md;
-- plaintext is intentionally not stored in this seed file.

insert into user_svc.users
    (id, username, email, name, phone, gender, balance, created_at)
values
    ('00000000-0000-4000-8000-00000000000a', '52000001', 'student.a@example.com', 'Student A', '0900000001', 'male',   20000000.00, now()),
    ('00000000-0000-4000-8000-00000000000b', '52000002', 'student.b@example.com', 'Student B', '0900000002', 'female',  1000000.00, now()),
    ('00000000-0000-4000-8000-00000000000c', '52000003', 'student.c@example.com', 'Student C', '0900000003', 'male',    5000000.00, now()),
    ('00000000-0000-4000-8000-00000000000d', '52000004', 'student.d@example.com', 'Student D', null,         null,      2000000.00, now()),
    ('00000000-0000-4000-8000-00000000000e', '52000005', 'student.e@example.com', 'Student E', '0900000005', 'female',        0.00, now())
on conflict (id) do update set
    username = excluded.username,
    email = excluded.email,
    name = excluded.name,
    phone = excluded.phone,
    gender = excluded.gender,
    balance = excluded.balance;

insert into auth_svc.accounts
    (id, username, password_hash, external_user_id, created_at)
values
    ('10000000-0000-4000-8000-00000000000a', '52000001', '$2b$12$jTNgSNvT2dSLs3kR3zu1zecKLYqYmtQykBZr0QEsgbIocBXiNCiJ.', '00000000-0000-4000-8000-00000000000a', now()),
    ('10000000-0000-4000-8000-00000000000b', '52000002', '$2b$12$jTNgSNvT2dSLs3kR3zu1zecKLYqYmtQykBZr0QEsgbIocBXiNCiJ.', '00000000-0000-4000-8000-00000000000b', now()),
    ('10000000-0000-4000-8000-00000000000c', '52000003', '$2b$12$jTNgSNvT2dSLs3kR3zu1zecKLYqYmtQykBZr0QEsgbIocBXiNCiJ.', '00000000-0000-4000-8000-00000000000c', now()),
    ('10000000-0000-4000-8000-00000000000d', '52000004', '$2b$12$jTNgSNvT2dSLs3kR3zu1zecKLYqYmtQykBZr0QEsgbIocBXiNCiJ.', '00000000-0000-4000-8000-00000000000d', now()),
    ('10000000-0000-4000-8000-00000000000e', '52000005', '$2b$12$jTNgSNvT2dSLs3kR3zu1zecKLYqYmtQykBZr0QEsgbIocBXiNCiJ.', '00000000-0000-4000-8000-00000000000e', now())
on conflict (id) do update set
    username = excluded.username,
    password_hash = excluded.password_hash,
    external_user_id = excluded.external_user_id;

-- Relative dates keep one semester current whenever the test database is reset.
insert into studentfee_svc.semester
    (semester_id, semester_name, school_year, start_date, end_date)
values
    ('20000000-0000-4000-8000-000000000001', 'Current Test Semester', 'TEST-CURRENT', current_date - 30, current_date + 120),
    ('20000000-0000-4000-8000-000000000002', 'Previous Test Semester', 'TEST-PREVIOUS', current_date - 210, current_date - 60)
on conflict (semester_id) do update set
    semester_name = excluded.semester_name,
    school_year = excluded.school_year,
    start_date = excluded.start_date,
    end_date = excluded.end_date;

-- Student A: enough balance and an unpaid invoice (8,000,000 VND).
-- Student B: insufficient balance and an unpaid invoice (7,500,000 VND).
-- Student C: a paid invoice used for duplicate-payment rejection tests.
-- Student D: deliberately has no invoice.
-- Student E: an unpaid invoice for Student A's pay-on-behalf flow (9,000,000 VND).
insert into studentfee_svc.tuition_invoice
    (id, student_id, semester_id, status, create_at)
values
    ('30000000-0000-4000-8000-00000000000a', '00000000-0000-4000-8000-00000000000a', '20000000-0000-4000-8000-000000000001', 'unpaid', now()),
    ('30000000-0000-4000-8000-00000000000b', '00000000-0000-4000-8000-00000000000b', '20000000-0000-4000-8000-000000000001', 'unpaid', now()),
    ('30000000-0000-4000-8000-00000000000c', '00000000-0000-4000-8000-00000000000c', '20000000-0000-4000-8000-000000000001', 'paid',   now()),
    ('30000000-0000-4000-8000-00000000000e', '00000000-0000-4000-8000-00000000000e', '20000000-0000-4000-8000-000000000001', 'unpaid', now())
on conflict (id) do update set
    student_id = excluded.student_id,
    semester_id = excluded.semester_id,
    status = excluded.status,
    create_at = excluded.create_at;

insert into studentfee_svc.invoice_items
    (invoice_items_id, invoice_id, subject_id, subject_name, registration_date, amount)
values
    ('40000000-0000-4000-8000-000000000001', '30000000-0000-4000-8000-00000000000a', 'TEST-A01', 'Software Testing Fundamentals', now() - interval '20 days', 3500000.00),
    ('40000000-0000-4000-8000-000000000002', '30000000-0000-4000-8000-00000000000a', 'TEST-A02', 'Service-Oriented Architecture', now() - interval '19 days', 4500000.00),
    ('40000000-0000-4000-8000-000000000003', '30000000-0000-4000-8000-00000000000b', 'TEST-B01', 'Database Systems', now() - interval '18 days', 3000000.00),
    ('40000000-0000-4000-8000-000000000004', '30000000-0000-4000-8000-00000000000b', 'TEST-B02', 'Web Application Development', now() - interval '17 days', 4500000.00),
    ('40000000-0000-4000-8000-000000000005', '30000000-0000-4000-8000-00000000000c', 'TEST-C01', 'Cloud Computing', now() - interval '16 days', 6000000.00),
    ('40000000-0000-4000-8000-000000000006', '30000000-0000-4000-8000-00000000000e', 'TEST-E01', 'Software Quality Assurance', now() - interval '15 days', 4000000.00),
    ('40000000-0000-4000-8000-000000000007', '30000000-0000-4000-8000-00000000000e', 'TEST-E02', 'Distributed Systems', now() - interval '14 days', 5000000.00)
on conflict (invoice_items_id) do update set
    invoice_id = excluded.invoice_id,
    subject_id = excluded.subject_id,
    subject_name = excluded.subject_name,
    registration_date = excluded.registration_date,
    amount = excluded.amount;

-- payment_svc.payment_intents and payment_svc.payments intentionally start
-- empty. Happy-path and history records must be created through the APIs under
-- test so seed execution never simulates a successful payment.

commit;

