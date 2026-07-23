# Tuition Payment Website

## Project overview

Tuition Payment Website is a university project that simulates an iBanking-style tuition payment system. An authenticated student can review profile and tuition data, inspect invoices by semester, add funds to a simulated balance, pay an invoice for themselves or another student, confirm a payment with an email OTP, and review payment history.

The application is implemented as a React frontend backed by an API gateway and four FastAPI services. Supabase is used as the data-access platform. This repository is a simulation; it does not integrate with a real bank or payment processor.

## Main features

- JWT-based login and session verification.
- Student profile and simulated account balance display.
- Semester selection and tuition invoice lookup.
- Invoice-item and calculated total display.
- Self-payment and payment on behalf of another student.
- Simulated balance deposit and debit operations.
- Six-digit email OTP confirmation with a 180-second application timer.
- Payment intent lifecycle: `pending`, `otp_sent`, `processing`, `confirmed`, and failure states used by the implementation.
- Payment history with payer and beneficiary information.
- Logout and client-side handling of invalid sessions.

## User roles

The source code supports one identifiable actor. The confirmed identity rule is that `username` is always the student's university ID (MSSV):

- **Student / authenticated user**: views tuition information and performs payment-related actions.

No role field, role claim, administrator route, or staff workflow is present. Any additional role is **TBD – Requires confirmation**.

## Technology stack

| Layer | Technology |
|---|---|
| Frontend | React 19, React Router, Axios, Vite 7, CSS |
| API gateway | FastAPI, HTTPX |
| Backend services | Python, FastAPI, Pydantic |
| Authentication | JWT (`python-jose`), bcrypt via Passlib, HTTP Bearer |
| Data access | Supabase Python client / PostgREST |
| Database | Supabase-hosted database; exact PostgreSQL DDL is not included |
| Email | SMTP using Python `smtplib` |

## Basic request flow

```text
Browser (React :5173)
        |
        | HTTP + Bearer JWT
        v
API Gateway (:8000)
   |        |          |           |
   v        v          v           v
Auth      User     Student Fee   Payment
:8001     :8002       :8003       :8004
   |        |          |           |
   +--------+----------+-----------+
                    |
                    v
          Supabase service schemas

Payment also calls User and Student Fee services and can send SMTP email.
```

## My role

Repository evidence currently supports the following portfolio activities:

- Analyzed source-derived functional requirements and business flows.
- Designed manual UI and API test cases.
- Prepared and executed a 53-case manual test suite with formal defect and execution-summary documentation.
- Documented potential issues identified through code review.
- Prepared a Postman collection and local environment template for future API execution.

Manual execution is supported by screenshots committed under [`docs/images`](docs/images/README.md). The exact tested commit and Chrome version were not recorded.

## Testing scope

The planned scope covers authentication, user profile and balance operations, semester and invoice retrieval, self/other-student payments, OTP confirmation, transaction state changes, payment history, API validation, basic authorization checks, UI behavior, and data consistency checks.

Out of scope for the current evidence set are performance testing, penetration testing, production readiness certification, real banking integration, comprehensive accessibility certification, and test automation execution.

## Testing types

- Functional testing
- UI testing
- API testing
- Negative and validation testing
- Role/access-control testing for authenticated versus unauthenticated access
- Basic regression testing
- Database validation after state-changing operations

## Testing techniques

- Equivalence partitioning
- Boundary value analysis
- Decision-table coverage for balance, invoice status, and OTP state
- State-transition testing for payment intents
- Error guessing for invalid identifiers, duplicate requests, upstream failures, and retries
- Requirement-based and use-case-based testing

## Tools

Tools evidenced by the repository are FastAPI OpenAPI/Swagger UI, Supabase, npm/Vite, Git, Postman, and Chrome. Manual API execution used Postman and UI execution used Chrome in a local environment.

## Test documentation

- [Feature overview and testable requirements](docs/requirements/feature-overview.md)
- [Test plan](docs/test-plan/test-plan.md)
- [Manual test cases](docs/test-cases/test-cases.md)
- [Defect report template](docs/bug-reports/defect-report-template.md)
- [Potential issues from code review](docs/bug-reports/potential-issues.md)
- [Manual execution test summary](docs/test-reports/test-summary-report.md)
- [Confirmed defect reports](docs/bug-reports/README.md)
- [Screenshot evidence guide](docs/images/README.md)
- [Reproducible Supabase database setup](docs/database/database-setup.md)
- [Postman usage and endpoint inventory](postman/README.md)

## Current testing status

**Execution Status: Completed with exceptions**

The suite contains 53 test cases: 51 executed and 2 Not Run. Results are 43 Passed, 5 Failed, 3 Blocked, and 2 Not Run. Five confirmed defects are documented under `docs/bug-reports/`. Two code-review hypotheses were confirmed through execution; access-control observations remain blocked pending policy confirmation.

## Screenshots

The repository contains 121 screenshots covering 50 of the 53 designed test cases. Evidence uses test-case IDs and numeric suffixes for multiple artifacts; see the [test evidence index](docs/images/README.md).

## Setup and run instructions

### Prerequisites

- Python compatible with the pinned packages in `backend/requirements.txt`
- Node.js and npm
- A Supabase project containing the schemas/tables expected by the repository code
- Optional SMTP credentials; without them, mail content is printed in development mode

### Database setup

The complete schema and synthetic test dataset are versioned under `supabase/`. Follow [the database setup guide](docs/database/database-setup.md). For a new linked test project, migrations and seed data can be applied without manually creating Dashboard tables:

```powershell
npx supabase link --project-ref <NEW_PROJECT_REF>
npx supabase db push --dry-run
npx supabase db push --include-seed
```

### Backend environment

Create `backend/.env` locally. Do not commit secrets.

```dotenv
SUPABASE_URL=<your-supabase-url>
SUPABASE_SERVICE_ROLE_KEY=<your-service-role-key>
JWT_SECRET=<shared-secret-for-all-services>
JWT_ALGORITHM=HS256
JWT_EXPIRE_MINUTES=60
AUTH_SVC_URL=http://localhost:8001
USER_SVC_URL=http://localhost:8002
STUDENTFEE_SVC_URL=http://localhost:8003
PAYMENT_SVC_URL=http://localhost:8004
USER_SERVICE_URL=http://localhost:8002/user
MAIL_FROM=no-reply@example.com
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=<optional-user>
SMTP_PASS=<optional-password>
```

From the repository root:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r backend\requirements.txt
```

Start each process in a separate terminal from `backend`:

```powershell
uvicorn auth.main:app --reload --port 8001
uvicorn users.main:app --reload --port 8002
uvicorn studentfee.main:app --reload --port 8003
uvicorn payment.main:app --reload --port 8004
uvicorn gateway.main:app --reload --port 8000
```

### Frontend

```powershell
cd frontend
npm install
npm run dev
```

The frontend defaults to `http://localhost:8000`; override it with `VITE_API_BASE_URL` when required.

### API documentation

When a service is running, its generated OpenAPI documentation is normally available at `/docs`, for example `http://localhost:8004/docs`. The gateway schema contains proxy routes and may not expose the detailed downstream request models.

## Known limitations

- Database migrations, DDL, seed data, and RLS policies are not included.
- No automated test suite or CI execution result is included; manual results and screenshot evidence are documented under `docs/`.
- The gateway does not currently proxy `POST /auth/signup`; direct-service behavior and desired gateway behavior require confirmation.
- The frontend references a current-intent endpoint that is not implemented by the payment router.
- Authorization policy for accessing another student's invoice/history and for balance operations is not formally specified.
- OTP duration is inconsistent between active code (180 seconds) and email text (5 minutes).
- The balance top-up flow is a simulation and has no external funding provider.
- Cross-service payment updates are not implemented as one database transaction.
- Formal browser support and deployment configuration are **TBD – Requires confirmation**.

## Repository structure

```text
backend/
  auth/             Authentication service
  users/            User profile and balance service
  studentfee/       Semester and tuition invoice service
  payment/          Intent, OTP, payment, history, and email logic
  gateway/          HTTP reverse-proxy API gateway
frontend/
  src/pages/        Login and Home screens
  src/services/     Axios API clients
docs/
  requirements/     Source-derived feature overview and requirements
  test-plan/        Test strategy and proposed schedule
  test-cases/       Manual test cases
  bug-reports/      Defect template and code-review findings
  test-reports/     Manual execution test summary
  images/           Sanitized execution screenshots and evidence index
postman/            Prepared collection, environment, and API inventory
supabase/            Reproducible database migration, local config, and test seed
```
