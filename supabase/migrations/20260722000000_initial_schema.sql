begin;

create extension if not exists pgcrypto with schema extensions;

create schema if not exists auth_svc;
create schema if not exists user_svc;
create schema if not exists studentfee_svc;
create schema if not exists payment_svc;

-- ---------------------------------------------------------------------------
-- Auth service
-- external_user_id is a logical cross-service reference to user_svc.users.id.
-- It deliberately has no cross-schema foreign key so the service boundary used
-- by the application remains explicit.
-- ---------------------------------------------------------------------------

create table auth_svc.accounts (
    id uuid primary key default gen_random_uuid(),
    username text not null,
    password_hash text not null,
    external_user_id uuid not null,
    created_at timestamptz not null default now(),
    constraint accounts_username_not_blank check (btrim(username) <> ''),
    constraint accounts_password_hash_not_blank check (btrim(password_hash) <> ''),
    constraint accounts_username_key unique (username),
    constraint accounts_external_user_id_key unique (external_user_id)
);

comment on column auth_svc.accounts.username is
    'Student ID (MSSV); exact institution-specific format is not enforced.';
comment on column auth_svc.accounts.external_user_id is
    'Logical reference to user_svc.users.id.';

-- ---------------------------------------------------------------------------
-- User service
-- ---------------------------------------------------------------------------

create table user_svc.users (
    id uuid primary key default gen_random_uuid(),
    username text not null,
    email text not null,
    name text not null,
    phone text,
    gender text,
    balance numeric(18, 2) not null default 0.00,
    created_at timestamptz not null default now(),
    constraint users_username_not_blank check (btrim(username) <> ''),
    constraint users_email_not_blank check (btrim(email) <> ''),
    constraint users_name_not_blank check (btrim(name) <> ''),
    constraint users_balance_non_negative check (balance >= 0),
    constraint users_username_key unique (username),
    constraint users_email_key unique (email)
);

comment on column user_svc.users.username is
    'Student ID (MSSV); exact institution-specific format is not enforced.';

-- ---------------------------------------------------------------------------
-- Student Fee service
-- ---------------------------------------------------------------------------

create table studentfee_svc.semester (
    semester_id uuid primary key default gen_random_uuid(),
    semester_name text not null,
    school_year text not null,
    start_date date not null,
    end_date date not null,
    constraint semester_name_not_blank check (btrim(semester_name) <> ''),
    constraint semester_school_year_not_blank check (btrim(school_year) <> ''),
    constraint semester_date_range_valid check (start_date <= end_date),
    constraint semester_name_school_year_key unique (semester_name, school_year)
);

create table studentfee_svc.tuition_invoice (
    id uuid primary key default gen_random_uuid(),
    student_id uuid not null,
    semester_id uuid not null,
    status text not null default 'unpaid',
    create_at timestamptz not null default now(),
    constraint tuition_invoice_semester_fk
        foreign key (semester_id)
        references studentfee_svc.semester (semester_id)
        on update cascade
        on delete restrict,
    constraint tuition_invoice_status_valid
        check (status in ('unpaid', 'paid', 'processing', 'failed')),
    constraint tuition_invoice_student_semester_key
        unique (student_id, semester_id)
);

comment on column studentfee_svc.tuition_invoice.student_id is
    'Logical reference to user_svc.users.id.';
comment on column studentfee_svc.tuition_invoice.create_at is
    'Name intentionally matches the active Pydantic response schema.';

create table studentfee_svc.invoice_items (
    invoice_items_id uuid primary key default gen_random_uuid(),
    invoice_id uuid not null,
    subject_id text not null,
    subject_name text not null,
    registration_date timestamptz not null,
    amount numeric(18, 2) not null,
    constraint invoice_items_invoice_fk
        foreign key (invoice_id)
        references studentfee_svc.tuition_invoice (id)
        on update cascade
        on delete cascade,
    constraint invoice_items_subject_id_not_blank check (btrim(subject_id) <> ''),
    constraint invoice_items_subject_name_not_blank check (btrim(subject_name) <> ''),
    constraint invoice_items_amount_non_negative check (amount >= 0),
    constraint invoice_items_invoice_subject_key unique (invoice_id, subject_id)
);

-- ---------------------------------------------------------------------------
-- Payment service
-- payer_user_id/student_id/invoice_id are logical cross-service references.
-- ---------------------------------------------------------------------------

create table payment_svc.payment_intents (
    id uuid primary key default gen_random_uuid(),
    payer_user_id uuid not null,
    payer_email text not null,
    student_id uuid not null,
    invoice_id uuid not null,
    amount numeric(18, 2) not null,
    status text not null default 'pending',
    otp_code text,
    otp_expires_at timestamptz,
    otp_attempts integer not null default 0,
    created_at timestamptz not null default now(),
    constraint payment_intents_payer_email_not_blank check (btrim(payer_email) <> ''),
    constraint payment_intents_amount_positive check (amount > 0),
    constraint payment_intents_status_valid
        check (status in ('pending', 'otp_sent', 'processing', 'confirmed', 'failed', 'expired')),
    constraint payment_intents_otp_format_valid
        check (otp_code is null or otp_code ~ '^[0-9]{6}$'),
    constraint payment_intents_otp_fields_consistent
        check (
            (otp_code is null and otp_expires_at is null)
            or (otp_code is not null and otp_expires_at is not null)
        ),
    constraint payment_intents_otp_attempts_non_negative check (otp_attempts >= 0)
);

comment on column payment_svc.payment_intents.payer_user_id is
    'Logical reference to user_svc.users.id.';
comment on column payment_svc.payment_intents.student_id is
    'Logical reference to user_svc.users.id.';
comment on column payment_svc.payment_intents.invoice_id is
    'Logical reference to studentfee_svc.tuition_invoice.id.';
comment on column payment_svc.payment_intents.otp_expires_at is
    'Active application rule: OTP expires 180 seconds after issuance.';

create table payment_svc.payments (
    id uuid primary key default gen_random_uuid(),
    intent_id uuid not null,
    paid_at timestamptz not null default now(),
    amount numeric(18, 2) not null,
    payer_balance_before numeric(18, 2) not null,
    payer_balance_after numeric(18, 2) not null,
    constraint payments_intent_fk
        foreign key (intent_id)
        references payment_svc.payment_intents (id)
        on update cascade
        on delete restrict,
    constraint payments_intent_id_key unique (intent_id),
    constraint payments_amount_positive check (amount > 0),
    constraint payments_balance_before_non_negative check (payer_balance_before >= 0),
    constraint payments_balance_after_non_negative check (payer_balance_after >= 0),
    constraint payments_balance_direction_valid check (payer_balance_after <= payer_balance_before)
);

-- ---------------------------------------------------------------------------
-- Query-supporting indexes
-- ---------------------------------------------------------------------------

create index idx_semester_date_range
    on studentfee_svc.semester (start_date, end_date);

create index idx_tuition_invoice_student
    on studentfee_svc.tuition_invoice (student_id);

create index idx_tuition_invoice_semester
    on studentfee_svc.tuition_invoice (semester_id);

create index idx_tuition_invoice_status
    on studentfee_svc.tuition_invoice (status);

create index idx_invoice_items_invoice
    on studentfee_svc.invoice_items (invoice_id);

create index idx_payment_intents_payer_created
    on payment_svc.payment_intents (payer_user_id, created_at desc);

create index idx_payment_intents_student_created
    on payment_svc.payment_intents (student_id, created_at desc);

create index idx_payment_intents_invoice_created
    on payment_svc.payment_intents (invoice_id, created_at desc);

create index idx_payment_intents_status
    on payment_svc.payment_intents (status);

create index idx_payments_paid_at
    on payment_svc.payments (paid_at desc);

-- The application catches this exact index/constraint name when duplicate open
-- payment attempts are submitted for one invoice.
create unique index uq_pi_one_open_per_invoice
    on payment_svc.payment_intents (invoice_id)
    where status in ('pending', 'otp_sent', 'processing');

-- ---------------------------------------------------------------------------
-- Data API access
--
-- The FastAPI services connect with the server-side service_role key. No table
-- privileges are granted to anon/authenticated, so the browser cannot use the
-- Supabase Data API directly. The backend remains responsible for user-level
-- authorization before it uses the elevated key.
-- ---------------------------------------------------------------------------

grant usage on schema auth_svc, user_svc, studentfee_svc, payment_svc
    to service_role;

grant all privileges on all tables in schema
    auth_svc, user_svc, studentfee_svc, payment_svc
    to service_role;

grant all privileges on all sequences in schema
    auth_svc, user_svc, studentfee_svc, payment_svc
    to service_role;

grant all privileges on all routines in schema
    auth_svc, user_svc, studentfee_svc, payment_svc
    to service_role;

alter default privileges in schema auth_svc
    grant all privileges on tables to service_role;
alter default privileges in schema user_svc
    grant all privileges on tables to service_role;
alter default privileges in schema studentfee_svc
    grant all privileges on tables to service_role;
alter default privileges in schema payment_svc
    grant all privileges on tables to service_role;

alter default privileges in schema auth_svc
    grant all privileges on sequences to service_role;
alter default privileges in schema user_svc
    grant all privileges on sequences to service_role;
alter default privileges in schema studentfee_svc
    grant all privileges on sequences to service_role;
alter default privileges in schema payment_svc
    grant all privileges on sequences to service_role;

revoke all privileges on all tables in schema
    auth_svc, user_svc, studentfee_svc, payment_svc
    from anon, authenticated;

-- Expose the custom schemas to hosted PostgREST without requiring a Dashboard
-- setting. This is an explicit database-level override; keep this list aligned
-- with supabase/config.toml.
alter role authenticator set pgrst.db_schemas =
    'public, auth_svc, user_svc, studentfee_svc, payment_svc';
alter role authenticator set pgrst.db_extra_search_path = 'public, extensions';

notify pgrst, 'reload config';
notify pgrst, 'reload schema';

commit;

