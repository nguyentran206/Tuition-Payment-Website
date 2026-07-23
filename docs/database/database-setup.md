# Reproducible Supabase Database Setup

## Purpose

This setup creates every schema, table, constraint, index, permission, and synthetic test record required by the current application source. Do not create tables manually in Supabase Dashboard.

The application uses its own `auth_svc.accounts` table and HS256 JWT implementation. It does not use Supabase Auth for student login.

## Source-of-truth files

```text
supabase/config.toml
supabase/migrations/20260722000000_initial_schema.sql
supabase/seed.sql
backend/.env.example
```

The migration also exposes the four custom schemas through PostgREST by setting `pgrst.db_schemas` on the `authenticator` role. This is a database-level override, so no manual **Exposed schemas** Dashboard step is required. Keep that SQL setting aligned with `api.schemas` in `config.toml`.

## Prerequisites

- Node.js/npm, or another supported Supabase CLI installation method.
- Docker Desktop or another Docker-compatible runtime for local Supabase.
- A Supabase account and a new project for hosted testing.
- Python/backend dependencies and Node/frontend dependencies from the root README.

Install or invoke the CLI:

```powershell
npm install --save-dev supabase
npx supabase --version
```

`supabase init` normally creates `supabase/config.toml`. This repository already commits that file, so do not overwrite it. Use the following only when bootstrapping an empty repository:

```powershell
npx supabase init
```

## Option A — Verify locally first

From the repository root, with Docker running:

```powershell
npx supabase start
npx supabase db reset
```

`db reset` recreates the local database, applies all migrations, and then executes `supabase/seed.sql`. A successful reset proves that the database can be reproduced from source.

Use the local API URL and server-side service key printed by `supabase start` if you want the FastAPI services to use the local stack.

## Option B — Deploy to a new hosted Supabase project

Create an empty Supabase project that you own, then run:

```powershell
npx supabase login
npx supabase link --project-ref <NEW_PROJECT_REF>
npx supabase db push --dry-run
npx supabase db push --include-seed
```

`--include-seed` is intended only for this disposable development/test project. Do not seed synthetic accounts into production.

No table creation is required in Dashboard. The migration creates and exposes:

- `auth_svc`
- `user_svc`
- `studentfee_svc`
- `payment_svc`

## Backend environment

Copy the template:

```powershell
Copy-Item backend\.env.example backend\.env
```

Fill only these values for the new hosted test project:

```dotenv
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<server-side-key>
```

The current code expects the legacy variable name `SUPABASE_SERVICE_ROLE_KEY`. Keep the key only in `backend/.env`; `.env` is ignored by Git. Never put it in frontend code, Postman exports, screenshots, or documentation.

The template includes two similarly named User service settings because the source uses both:

- `USER_SVC_URL=http://localhost:8002` is read through `backend/config.py` by Payment.
- `USER_SERVICE_URL=http://localhost:8002/user` is read directly by Auth signup.

Do not merge them without updating source code because they require different URL shapes.

## Synthetic test accounts

All usernames are student IDs (MSSV). All accounts use the same synthetic local-test password: `Test@123`. Only its bcrypt hash is stored in `seed.sql`.

| Fixture | MSSV | User UUID | Balance | Invoice state | Invoice total |
|---|---|---|---:|---|---:|
| Student A | `52000001` | `00000000-0000-4000-8000-00000000000a` | 20,000,000 | Unpaid | 8,000,000 |
| Student B | `52000002` | `00000000-0000-4000-8000-00000000000b` | 1,000,000 | Unpaid | 7,500,000 |
| Student C | `52000003` | `00000000-0000-4000-8000-00000000000c` | 5,000,000 | Paid | 6,000,000 |
| Student D | `52000004` | `00000000-0000-4000-8000-00000000000d` | 2,000,000 | No invoice | N/A |
| Student E | `52000005` | `00000000-0000-4000-8000-00000000000e` | 0 | Unpaid; target for Student A | 9,000,000 |

The current semester uses dates relative to the reset date, so it remains current whenever the seed is reapplied. Payment intent/payment tables start empty; successful transactions must be created through the APIs under test.

Student C's paid invoice is an isolated fixture for already-paid rejection testing. It does not claim that a payment was executed, and no synthetic payment ledger row is inserted for it.

## Start the application

Start each process in a separate terminal from `backend`:

```powershell
uvicorn auth.main:app --reload --port 8001
uvicorn users.main:app --reload --port 8002
uvicorn studentfee.main:app --reload --port 8003
uvicorn payment.main:app --reload --port 8004
uvicorn gateway.main:app --reload --port 8000
```

With SMTP credentials empty, OTP email is printed in the Payment service console. The application rule is exactly 180 seconds even though the current mail template still says five minutes; that text mismatch remains a code-review verification item.

## Smoke-test order

1. `GET http://localhost:8000/`
2. `POST http://localhost:8000/auth/login` using Student A.
3. `GET /auth/verify` with the returned bearer token.
4. `GET /user/me`.
5. `GET /studentfee/semesters`.
6. `GET /studentfee/my-invoice`.
7. Verify Student A's item sum is 8,000,000.
8. Create intent → send OTP → confirm through Payment APIs.
9. Verify balance, invoice, intent, payment, and history records.

Do not call `POST /studentfee/pay/{invoice_id}` before the Payment happy path; it marks the invoice paid immediately.

## Database verification queries

Run from SQL Editor or a PostgreSQL client after migration/seed:

```sql
select schema_name
from information_schema.schemata
where schema_name in ('auth_svc', 'user_svc', 'studentfee_svc', 'payment_svc')
order by schema_name;

select username, balance
from user_svc.users
order by username;

select i.student_id, i.status, sum(ii.amount) as total_amount
from studentfee_svc.tuition_invoice i
join studentfee_svc.invoice_items ii on ii.invoice_id = i.id
group by i.id, i.student_id, i.status
order by i.student_id;

select indexname, indexdef
from pg_indexes
where schemaname = 'payment_svc'
  and indexname = 'uq_pi_one_open_per_invoice';

select rolname, rolconfig
from pg_roles
where rolname = 'authenticator';
```

Expected seed counts:

```sql
select
  (select count(*) from auth_svc.accounts) as accounts,
  (select count(*) from user_svc.users) as users,
  (select count(*) from studentfee_svc.semester) as semesters,
  (select count(*) from studentfee_svc.tuition_invoice) as invoices,
  (select count(*) from studentfee_svc.invoice_items) as invoice_items,
  (select count(*) from payment_svc.payment_intents) as payment_intents,
  (select count(*) from payment_svc.payments) as payments;
```

Expected result immediately after reset: `5, 5, 2, 4, 7, 0, 0`.

## Resetting test data

For local Supabase:

```powershell
npx supabase db reset
```

For a disposable linked remote test project, review the linked project carefully before any destructive reset. Prefer creating new invoices/users or rebuilding only when no evidence must be retained.

## Source compatibility decisions

- `username` is stored as MSSV in both Auth and User schemas.
- Invoice timestamp remains `create_at` because the Pydantic model requires that exact name.
- `payment_intents.otp_attempts` uses the plural form required by `payment/repo.py`.
- `payments.intent_id` is unique because repository upsert uses `on_conflict="intent_id"`.
- Partial unique index is exactly `uq_pi_one_open_per_invoice`, matching Payment error handling.
- Payment intent status values cover all active transitions: `pending`, `otp_sent`, `processing`, `confirmed`, `failed`, and `expired`.
- Invoice status values exactly match its Pydantic literal: `unpaid`, `paid`, `processing`, and `failed`.
- Cross-service IDs are logical references; only same-service relationships use foreign keys.

## Known source conflicts not changed by database setup

- Auth signup expects `USER_SERVICE_URL`, while Payment/config use `USER_SVC_URL`.
- Gateway does not proxy `POST /auth/signup`; call Auth service directly if signup is tested.
- Frontend calls `/payment/intents/current`, but Payment has no corresponding backend route.
- OTP is enforced as 180 seconds in service/UI, while email content says five minutes.
- Some sensitive resource routes do not yet enforce owner authorization. A server key bypasses RLS, so FastAPI authorization must be fixed and tested separately.

