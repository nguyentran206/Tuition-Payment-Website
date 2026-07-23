# Test Plan

## 1. Introduction

This plan defines the manual testing approach used for the Tuition Payment Website. It is based on behavior observable in the repository and should be read together with the completed execution summary and recorded case results.

## 2. Objectives

- Verify that implemented user flows satisfy the source-derived requirements.
- Validate request/response behavior across the gateway and four FastAPI services.
- Verify authentication boundaries and identify missing authorization controls.
- Validate invoice totals, simulated balance updates, payment state transitions, and history data.
- Exercise positive, negative, boundary, duplicate, and failure paths.
- Produce reproducible evidence without exposing credentials, JWTs, OTPs, or personal data.

## 3. Scope

### 3.1 In-scope features

- Login, token verification, token expiry, logout, and protected-route behavior.
- Direct Auth-service signup behavior, with gateway limitation recorded separately.
- User profile creation/lookups and simulated deposit/debit.
- Semester listing, own/other invoice retrieval, invoice items, totals, and paid status.
- Self-payment and payment for another student.
- Payment intent creation, OTP send/resend, confirmation, cancellation, and concurrency guards.
- Payment history and username enrichment.
- Frontend validation, messages, navigation, formatting, modals, timer, and empty states.
- API status, body, headers, authentication, path/query/body validation, and upstream failure handling.
- Database validation for records changed by deposit, debit, invoice payment, intent, and payment creation.
- Basic regression around the critical login-to-payment flow.

### 3.2 Out-of-scope features

- Real bank, card, e-wallet, or payment-gateway settlement.
- Performance/load/stress testing.
- Security penetration testing or formal security certification.
- Automated UI/API execution; no automation framework exists in the repository.
- Production deployment, disaster recovery, and production monitoring.
- Formal accessibility conformance certification.
- Admin/staff workflows, refunds, partial payment, scholarships, and discounts, because they are not implemented.
- Verification of unknown database DDL/RLS constraints until schema artifacts are supplied.

## 4. Test approach

Testing should proceed from isolated APIs to integrated UI flows:

1. Prepare non-production data and confirm service health/configuration.
2. Validate Auth and token handling.
3. Validate User and Student Fee reads and balance operations.
4. Validate payment intent/OTP state transitions through APIs.
5. Validate end-to-end self-payment and other-student payment in the UI.
6. Validate stored data after each state-changing action.
7. Re-run a focused regression set after fixes.

Expected behavior comes from `docs/requirements/feature-overview.md`. When runtime behavior differs, first determine whether the requirement is supported by active source code. A code-review hypothesis becomes a confirmed defect only after reproduction and evidence.

## 5. Test types

| Test type | Planned coverage |
|---|---|
| Functional | User and payment workflows, success and alternate flows |
| UI | Inputs, buttons, tables, modals, navigation, formatting, and messages |
| API | Gateway/downstream status, body, auth, validation, and errors |
| Negative | Invalid credentials, values, IDs, state, OTP, and duplicate actions |
| Boundary value | Decimal amount precision/range, OTP length, zero/negative balance operations, timer boundary |
| Validation | Pydantic schemas plus frontend validation |
| Access control | Missing/invalid token, resource ownership hypotheses, public endpoints |
| State transition | Payment intent lifecycle and invoice status |
| Basic regression | Login, invoice display, self-payment, other-payment, top-up, history |
| Database validation | Balance, invoice, intent, OTP fields, and payment record consistency |

## 6. Test techniques

- Equivalence partitioning for credentials, identifiers, emails, amounts, and OTPs.
- Boundary value analysis for amount `0`, smallest valid decimal, precision limits, balance equal/below invoice, OTP length, and expiry time.
- Decision tables for invoice status × balance × terms acceptance and OTP state × code validity × expiry.
- State-transition testing for `pending → otp_sent → processing → confirmed`, cancellation/failure, and retry paths.
- Use-case testing for self-payment and payment for another student.
- Error guessing for duplicate requests, stale balances, invalid UUIDs, service timeout/unavailability, and repeated clicks.

## 7. Test environment

### 7.1 Proposed local environment

| Component | Configuration |
|---|---|
| Frontend | Vite development server, default `http://localhost:5173` |
| Gateway | FastAPI/Uvicorn, `http://localhost:8000` |
| Auth | FastAPI/Uvicorn, `http://localhost:8001` |
| User | FastAPI/Uvicorn, `http://localhost:8002` |
| Student Fee | FastAPI/Uvicorn, `http://localhost:8003` |
| Payment | FastAPI/Uvicorn, `http://localhost:8004` |
| Database | Dedicated non-production Supabase project |
| Email | Test mailbox/SMTP sandbox; development console mode only when OTP can be captured safely |
| Browser/OS | TBD – Requires confirmation |

Record exact OS, browser/version, commit SHA, database dataset version, timezone, service configuration (without secrets), and run date in execution evidence.

## 8. Test data requirements

- One valid student with an unpaid, positive-total invoice in a known semester.
- One valid student with sufficient balance.
- One valid student with insufficient balance.
- One student with a paid invoice.
- One student with no invoice for a selected/current semester.
- A second student for payment-on-behalf scenarios.
- Invoice with multiple items and known sum; optionally an empty-item or zero-total invoice for validation.
- Valid and invalid login credentials, invalid email samples, malformed/unknown UUIDs.
- OTP values captured from a controlled test mailbox or development mail output.
- Data setup for concurrent balance update and duplicate confirmation tests.

Use synthetic data only. Do not place passwords, service keys, full JWTs, live OTPs, or personally identifiable student data in committed evidence.

## 9. Entry criteria

- Target commit is identified and deployable to a non-production environment.
- Required Supabase schemas and representative test data are available.
- All five backend processes and frontend can start.
- Services use one non-default JWT secret in the test environment.
- Tester can access generated API docs and a controlled email destination.
- Test-case baseline is reviewed and open `TBD` items affecting expected results are resolved or explicitly accepted.
- Database read access for verification is available without exposing production data.

## 10. Exit criteria

- All planned high-priority test cases have been executed.
- Actual results and evidence are recorded for every executed case.
- No open confirmed Critical/High-severity defect blocks login, invoice retrieval, balance integrity, or payment integrity, unless formally accepted.
- Failed/blocked cases and accepted risks are documented.
- Requirement-to-test traceability and summary counts are updated.
- No sensitive information is present in committed artifacts.

These are proposed criteria; stakeholder acceptance thresholds are **TBD – Requires confirmation**.

## 11. Suspension and resumption criteria

Suspend affected testing when:

- Required services or Supabase are unavailable for repeated attempts.
- Test data is corrupt or shared changes make results non-repeatable.
- A defect risks unintended mass email or destructive balance/invoice changes.
- JWT/SMTP/Supabase configuration is inconsistent across services.
- A critical data-integrity defect invalidates later payment results.

Resume after the environment is stable, affected data is reset, the blocking fix/configuration is deployed, and a smoke check succeeds.

## 12. Defect management process

1. Reproduce the issue at least once; repeat according to severity/risk.
2. Compare against the source-derived requirement and current product decision.
3. Capture sanitized request/response, screen, logs, and relevant database state.
4. Create a report using `docs/bug-reports/defect-report-template.md`.
5. Assign severity and priority independently.
6. Link the test case and requirement.
7. Retest the same build/configuration after a fix, then run relevant regression cases.
8. Close only when expected behavior is observed and evidence is stored.

Code-review findings remain in `potential-issues.md` with `Not Confirmed` status until executed.

## 13. Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| No DDL/migrations | Database expectations may be incomplete | Request schema export; label inferred relationships; validate actual metadata before DB testing |
| Shared mutable test data | Payment and balance tests interfere | Use isolated users/invoices and reset scripts approved by the owner |
| Cross-service non-transactional flow | Partial updates can corrupt test state | Snapshot all related records before/after; test failure injection in a disposable environment |
| Email dependency | OTP flow may be blocked or leak data | Use test SMTP inbox or development mode with sanitized logs |
| Default JWT secret fallback | Environment may be misconfigured | Set one explicit test secret for all services; never commit it |
| Unspecified authorization | Expected 403/ownership policy is unclear | Execute exploratory checks and obtain product decision before formalizing requirements |
| Gateway/downstream mismatch | Requests may work direct but fail through UI | Test both gateway and direct service when diagnosing; user-facing acceptance uses gateway |
| No formal seed data | Boundary cases may be hard to reproduce | Create a documented synthetic data matrix after schema confirmation |

## 14. Deliverables

- Feature overview and testable requirements.
- Test plan.
- Manual test-case suite.
- Defect report template.
- Potential code-review issue register.
- Updated manual execution test summary.
- Postman collection and environment template.
- Sanitized execution evidence after testing begins.

## 15. Roles and responsibilities

| Role | Responsibility |
|---|---|
| Tester (proposed) | Refine requirements, prepare data, execute tests, record evidence, report/retest defects, update summary |
| Developer/project owner | Clarify TBD rules, provide schema/environment, fix defects, support root-cause analysis |
| Reviewer/stakeholder | Confirm scope, authorization/business decisions, risk acceptance, and exit decision |

Named assignees are **TBD – Requires confirmation**.

## 16. Proposed schedule

| Phase | Suggested duration | Output |
|---|---:|---|
| Requirement/TBD review | 0.5–1 day | Approved baseline and clarified policies |
| Environment/data preparation | 0.5–1 day | Stable test environment and data matrix |
| API functional testing | 1–2 days | API results and defect reports |
| UI/end-to-end testing | 1–2 days | UI/E2E results and evidence |
| Data/access/exploratory testing | 1 day | Integrity and access findings |
| Retest and regression | 0.5–1 day per build | Retest evidence and updated statuses |
| Summary and portfolio cleanup | 0.5 day | Final report and sanitized artifacts |

This is an estimate, not an execution record.

## 17. Assumptions and dependencies

- Supabase implements the fields referenced by repositories and supplies appropriate defaults.
- `username` is confirmed to be the student's MSSV; the allowed MSSV length/pattern remains TBD.
- The authoritative OTP lifetime is 180 seconds.
- Currency is displayed as VND; rounding/storage policy remains TBD.
- Gateway port and service ports match the repository defaults.
- Time-sensitive OTP tests use controlled clocks or carefully recorded timestamps.
- Direct database inspection is read-only except for approved test-data setup/reset.
- External network/email availability and browser matrix require confirmation.
