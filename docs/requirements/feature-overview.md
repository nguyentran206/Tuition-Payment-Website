# Feature Overview and Testable Requirements

## Document control

| Field | Value |
|---|---|
| Project | Tuition Payment Website |
| Basis | Repository source code reviewed on 2026-07-22 |
| Status | Source-derived baseline; runtime confirmation pending |
| Intended audience | Developers, testers, reviewers, and portfolio evaluators |

## System actors

| Actor | Evidence-based capability |
|---|---|
| Unauthenticated visitor | Open the login page and submit credentials. The Auth service also defines signup and verify APIs, although signup is not proxied by the current gateway. |
| Authenticated student/user | Uses MSSV as `username`; views profile, semesters, invoices, and history; adds simulated funds; creates and manages a payment intent; pays for self or another student; logs out. |
| Internal payment service | Calls User and Student Fee services, writes payment data, and sends email. |

No administrator, cashier, or staff role is implemented. Additional roles are **TBD – Requires confirmation**.

## Inferred data model

The repository contains data-access code but no DDL or migrations. The following are logical relationships, not confirmed database constraints.

| Schema/table | Fields referenced in active code | Logical relationships |
|---|---|---|
| `auth_svc.accounts` | `id`, `username`, `password_hash`, `external_user_id` | `external_user_id` points to `user_svc.users.id` |
| `user_svc.users` | `id`, `username`, `email`, `name`, `phone`, `gender`, `balance`, `created_at` | User is payer and/or invoice owner |
| `studentfee_svc.semester` | `semester_id`, `semester_name`, `school_year`, `start_date`, `end_date` | Semester has tuition invoices |
| `studentfee_svc.tuition_invoice` | `id`, `student_id`, `semester_id`, `status`, `create_at` | Invoice belongs to a user and semester |
| `studentfee_svc.invoice_items` | `invoice_items_id`, `invoice_id`, `subject_id`, `subject_name`, `registration_date`, `amount` | Item belongs to an invoice |
| `payment_svc.payment_intents` | `id`, `payer_user_id`, `payer_email`, `student_id`, `invoice_id`, `amount`, `status`, `otp_code`, `otp_expires_at`, `otp_attempts`, `created_at` | Intent links payer, beneficiary, and invoice |
| `payment_svc.payments` | `id`, `intent_id`, `paid_at`, `amount`, `payer_balance_before`, `payer_balance_after` | Payment is upserted by intent |

Exact types, nullability, foreign keys, unique constraints, RLS policies, and delete/update actions are **TBD – Requires confirmation**.

## Module AUTH — Authentication

| Attribute | Description |
|---|---|
| Module ID | AUTH |
| Purpose | Authenticate a user, issue a JWT, optionally create an account/profile, and verify a token. |
| Actors | Unauthenticated visitor; Auth service; User service during signup |
| Preconditions | Auth and User services can access configured Supabase schemas; services share the JWT secret/algorithm. |
| Main flow | Submit username/password → find account → verify bcrypt hash → issue bearer JWT containing `sub`, `username`, `iat`, `exp`, and `iss` → frontend stores token. |
| Alternative flows | Signup creates a User profile before creating an Auth account. Verify decodes an existing bearer token. |
| Validation rules | Login fields are required strings through Pydantic. Signup email uses `EmailStr`. Duplicate username returns 400. JWT expiry defaults to 60 minutes. |
| Error handling | Invalid credentials: 401. Invalid/expired verify token: 401. Invalid email/body: 422. User-service signup failure is mapped to 400. |
| Related APIs | `POST /auth/login`; `POST /auth/signup` (Auth service direct; not currently gateway-proxied); `GET /auth/verify` |
| Related tables | `auth_svc.accounts`, `user_svc.users` |
| Source references | `backend/auth/router.py`, `service.py`, `schemas.py`, `repo.py`, `utils.py`; `backend/gateway/main.py`; `frontend/src/pages/Login/Login.jsx`; `frontend/src/services/authService.js` |
| Open questions | MSSV length/pattern, password policy, account lockout, refresh token, signup exposure, and rollback if Auth account creation fails are TBD. The identity rule `username = MSSV` is confirmed. |

### AUTH requirements

| ID | Testable requirement |
|---|---|
| REQ-AUTH-001 | The login API shall return a bearer access token and username for a valid stored username/password pair. |
| REQ-AUTH-002 | The login API shall return 401 with `Invalid credentials` when the username is unknown or the password is incorrect. |
| REQ-AUTH-003 | The login request shall require both `username` and `password`. |
| REQ-AUTH-004 | An issued JWT shall include `sub`, `username`, `iat`, `exp`, and `iss=auth_svc`, using the configured algorithm and expiry. |
| REQ-AUTH-005 | Protected services shall reject a missing Authorization header with 401. |
| REQ-AUTH-006 | Protected services shall reject invalid or expired JWTs with 401. |
| REQ-AUTH-007 | Signup shall reject an existing Auth username with 400 when called directly on the Auth service. |
| REQ-AUTH-008 | Signup shall validate email format and create a User profile before the Auth account when called directly. |
| REQ-AUTH-009 | Logout shall remove the locally stored token and navigate to `/login`. |

## Module USER — Profile and simulated balance

| Attribute | Description |
|---|---|
| Module ID | USER |
| Purpose | Create and retrieve user profiles and update the simulated balance. |
| Actors | Auth service for public profile creation; authenticated user/payment service for reads and balance changes |
| Preconditions | Supabase `user_svc.users` is available; protected requests carry a valid JWT. |
| Main flow | Resolve current user from JWT `sub` → return profile. Deposit/debit reads balance and updates only if the stored balance still equals the previously read value. |
| Alternative flows | Look up by UUID or username. Deposit adds funds; debit subtracts funds. |
| Validation rules | Create requires non-empty username, valid email, and name. Amount must be `> 0`, max 18 digits and 2 decimal places. Debit requires sufficient funds. |
| Error handling | Missing fields/DB create errors: 400. User missing: intended 404 except for the overwritten username helper noted in code review. Insufficient funds or concurrent balance change: 409. Pydantic validation: 422. |
| Related APIs | `POST /user/create`; `GET /user/me`; `GET /user/by-id/{user_id}`; `GET /user/by-username/{username}`; `POST /user/{user_id}/debit`; `POST /user/{user_id}/deposit` |
| Related tables | `user_svc.users` |
| Source references | `backend/users/router.py`, `service.py`, `schemas.py`, `repo.py`, `utils.py`; `frontend/src/services/userService.js`; `frontend/src/pages/Home/Home.jsx` |
| Open questions | Who may debit/deposit another user, top-up source, maximum balance, format rules, and duplicate email behavior are TBD. |

### USER requirements

| ID | Testable requirement |
|---|---|
| REQ-USER-001 | The current-user API shall return the profile matching JWT `sub`, with username fallback only when lookup by `sub` fails. |
| REQ-USER-002 | Protected user lookup APIs shall require a valid bearer token. |
| REQ-USER-003 | User creation shall require username, valid email, and name. |
| REQ-USER-004 | Debit and deposit requests shall accept only positive decimal amounts with at most two decimal places and 18 total digits. |
| REQ-USER-005 | Debit shall return 409 and preserve the balance when available balance is below the requested amount. |
| REQ-USER-006 | A successful debit/deposit shall return the new balance. |
| REQ-USER-007 | A concurrent balance change shall cause the compare-and-update operation to return 409 with a retry message. |

## Module FEE — Semesters and tuition invoices

| Attribute | Description |
|---|---|
| Module ID | FEE |
| Purpose | Return semesters, invoice details/items, totals, and update invoice payment status. |
| Actors | Authenticated student; Payment service; another-student lookup endpoint is public in active router code |
| Preconditions | Semester/invoice/item data exists in Supabase. Own-invoice and pay requests have JWT. |
| Main flow | Select semester → fetch invoice by student and semester → fetch items → sum item amounts → return typed invoice. |
| Alternative flows | Without `semester_id`, choose a semester whose dates include today. Another student's flow always uses current semester. Payment service marks invoice `paid`. |
| Validation rules | Response status must match `unpaid|paid|processing|failed`; total is sum of item amounts; response dates must parse into schema types. |
| Error handling | Missing current semester/invoice/update: 404. Empty semester list: 404. Schema mismatch: framework response-validation error. |
| Related APIs | `GET /studentfee/my-invoice`; `GET /studentfee/invoice/{username}` (path value is actually used as student UUID); `POST /studentfee/pay/{invoice_id}`; `GET /studentfee/semesters` |
| Related tables | `studentfee_svc.semester`, `tuition_invoice`, `invoice_items` |
| Source references | `backend/studentfee/router.py`, `service.py`, `schemas.py`, `repo.py`, `utils.py`; `frontend/src/services/studentFeeService.js`; `frontend/src/pages/Home/Home.jsx` |
| Open questions | Semester ordering, multiple invoices per semester, invoice ownership check, status transitions, currency/rounding, and public access policy are TBD. |

### FEE requirements

| ID | Testable requirement |
|---|---|
| REQ-FEE-001 | The semester API shall return configured semester records to an authenticated request or 404 when none exist. |
| REQ-FEE-002 | Own invoice lookup shall use the JWT subject and optional `semester_id`. |
| REQ-FEE-003 | Own invoice lookup without `semester_id` shall use a semester whose date range includes the current date. |
| REQ-FEE-004 | Invoice responses shall include invoice items and `total_amount` equal to the sum of item amounts. |
| REQ-FEE-005 | Missing semester or invoice data shall return 404 with the implemented detail message. |
| REQ-FEE-006 | Another-student invoice lookup shall use that student's identifier and current semester. |
| REQ-FEE-007 | Marking an existing invoice paid shall set status to `paid` and return the invoice with items. |

## Module PAY — Payment intent, OTP, and confirmation

| Attribute | Description |
|---|---|
| Module ID | PAY |
| Purpose | Orchestrate a tuition payment against simulated balance with email OTP confirmation. |
| Actors | Authenticated payer; Payment service; User service; Student Fee service; SMTP server |
| Preconditions | Valid JWT; payer and invoice exist; invoice is unpaid; total is positive; service dependencies are reachable. |
| Main flow | Create intent → obtain payer email → store `pending` intent → send six-digit OTP and set `otp_sent` → validate OTP/expiry → lock to `processing` → debit payer → mark invoice paid → mark intent confirmed → upsert payment → send receipt. |
| Alternative flows | Pay for another student by providing `student_id`; resend an expired OTP; cancel an intent; development mail mode prints instead of sending. |
| Validation rules | OTP request body matches `^\d{6}$`; active code sets expiry to 180 seconds; invoice must not be paid; total must be positive; only `pending`/`otp_sent` can confirm; optimistic lock permits one processor. |
| Error handling | Create/send wrappers usually map unexpected errors to 400; semantic confirm errors map to 422; upstream HTTP status is preserved by external calls; unreachable upstream maps to 502; unexpected confirm errors map to 500. |
| Related APIs | `POST /payment/intents`; `POST /payment/intents/{id}/send-otp`; `POST /payment/intents/{id}/confirm`; `POST /payment/intents/{id}/cancel` |
| Related tables | `payment_svc.payment_intents`, `payments`; reads/updates User and Student Fee tables through services |
| Source references | `backend/payment/router.py`, `service.py`, `repo.py`, `schemas.py`, `external.py`, `mailer.py`, `utils.py`; `frontend/src/services/paymentService.js`; `frontend/src/pages/Home/Home.jsx` |
| Open questions | Ownership authorization, OTP attempt limit, cryptographic OTP generation/storage, cancellation states, and recovery/compensation are TBD. The authoritative OTP lifetime is confirmed as 180 seconds. |

### PAY requirements

| ID | Testable requirement |
|---|---|
| REQ-PAY-001 | Payment APIs shall require a valid bearer token. |
| REQ-PAY-002 | Intent creation without `student_id` shall load the payer's invoice for the requested/current semester. |
| REQ-PAY-003 | Intent creation with `student_id` shall load that student's current-semester invoice. |
| REQ-PAY-004 | Intent creation shall reject paid invoices and invoices with a non-positive total. |
| REQ-PAY-005 | An open intent shall store payer, beneficiary, invoice, amount, email, and `pending` status. |
| REQ-PAY-006 | Sending OTP shall generate a zero-padded six-digit value, set an expiry, increment `otp_attempts`, and set status `otp_sent`. |
| REQ-PAY-007 | Confirm shall reject a body that is not exactly six numeric characters at request validation. |
| REQ-PAY-008 | Confirm shall reject missing, incorrect, expired, confirmed, processing, or otherwise disallowed intent states without a second debit. |
| REQ-PAY-009 | Successful confirm shall debit exactly the intent amount, mark the invoice paid, confirm the intent, clear OTP fields, and upsert one payment record with balances before/after. |
| REQ-PAY-010 | The optimistic processing transition shall prevent concurrent confirmation of the same intent. |
| REQ-PAY-011 | Cancel shall return the intent ID with `failed` status for the current implementation. |
| REQ-PAY-012 | Development email mode shall avoid SMTP login when SMTP credentials are absent. |

## Module HIST — Payment history

| Attribute | Description |
|---|---|
| Module ID | HIST |
| Purpose | Display completed payments involving a student as payer or beneficiary. |
| Actors | Authenticated user |
| Preconditions | Valid token and identifiers; corresponding invoice/intent/payment records may exist. |
| Main flow | Validate an invoice exists for student/semester → find intents involving the student → find payments → enrich with payer/student usernames → return newest first. |
| Alternative flows | Return an empty list when no invoice, intents, or payments exist. UI locally filters and sorts self-history. |
| Validation rules | Both path parameters are required strings. Username lookup failures fall back to UUID. |
| Error handling | Repository empty results become `[]`; router maps unexpected exceptions to 400. |
| Related APIs | `GET /payment/payments/history/{student_id}/{semester_id}` |
| Related tables | `studentfee_svc.tuition_invoice`, `payment_svc.payment_intents`, `payment_svc.payments`, `user_svc.users` |
| Source references | `backend/payment/router.py`, `repo.py`, `external.py`; `frontend/src/pages/Home/Home.jsx` |
| Open questions | Authorization to view another user's history and exact semester filtering behavior are TBD. |

### HIST requirements

| ID | Testable requirement |
|---|---|
| REQ-HIST-001 | History shall require a valid bearer token and both student and semester identifiers. |
| REQ-HIST-002 | History shall return an empty list when no matching invoice or completed payment data exists. |
| REQ-HIST-003 | Returned history rows shall include payment data plus payer/student IDs and display usernames when resolvable. |
| REQ-HIST-004 | Returned payment records shall be ordered by `paid_at` descending at the repository query level. |

## Module UI — React user interface

| Attribute | Description |
|---|---|
| Module ID | UI |
| Purpose | Provide login, profile, invoice, payment, OTP, top-up, history, and logout interactions. |
| Actors | Visitor and authenticated student |
| Preconditions | Frontend and gateway are reachable; backend data exists for populated views. |
| Main flow | Login → load profile/semesters/invoice/history → accept terms → check balance → create intent/send OTP → confirm → refresh displayed data. |
| Alternative flows | Other-student lookup/payment; insufficient-balance top-up; cancel; resend after timer; help/terms modals. |
| Validation rules | Login blocks empty fields. Payment button requires terms checkbox. Top-up must be numeric and positive and UI requires resulting balance to cover invoice. OTP input strips non-digits, limits six characters, and disables confirm until length six. |
| Error handling | Alerts for login; messages/modals for payment; 401/404 current-user response removes token and redirects; missing data shows empty states. |
| Related APIs | All gateway endpoints used by service files; frontend also attempts `GET /payment/intents/current`, which has no backend route. |
| Related tables | Indirect through APIs |
| Source references | `frontend/src/App.jsx`; `pages/Login/Login.jsx`; `pages/Home/Home.jsx`; `services/*.js`; `utils/format.js` |
| Open questions | Supported browsers, accessibility target, responsive breakpoints, and whether direct `/home` navigation should use a route guard are TBD. |

### UI requirements

| ID | Testable requirement |
|---|---|
| REQ-UI-001 | Login shall block submission when username or password is empty and display the implemented Vietnamese message. |
| REQ-UI-002 | Successful login shall store the token and navigate to `/home`; invalid login shall display the backend detail. |
| REQ-UI-003 | Home shall redirect to `/login` when no token exists or current-user lookup returns 401/404. |
| REQ-UI-004 | The UI shall display profile, semester, invoice item, total, status, balance, and history data returned by APIs. |
| REQ-UI-005 | Self and other-student payment buttons shall remain disabled until terms are accepted. |
| REQ-UI-006 | Insufficient balance shall open the top-up flow; top-up shall reject non-positive/non-numeric values. |
| REQ-UI-007 | OTP input shall accept only digits, enforce six-character maximum, and enable confirmation only at six digits. |
| REQ-UI-008 | The UI timer shall count down from 180 seconds and enable resend at zero. |
| REQ-UI-009 | Dates shall display in the Asia/Ho_Chi_Minh timezone and currency shall use Vietnamese numeric formatting. |

## Traceability note

Each requirement above is referenced by at least one test case in `docs/test-cases/test-cases.md`. A requirement describes observable active-code behavior; uncertain desired behavior remains an open question instead of being promoted to a requirement.
