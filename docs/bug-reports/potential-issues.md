# Potential Issues Identified Through Code Review

## Important notice

This file began as a static code-review register. Items now show whether execution reproduced the suspected behavior, remained untested, or was observed but blocked pending a business/access-control policy. A reproduced item is linked to its formal defect report when classification is unambiguous.

## PI-AUTH-001 — Gateway does not proxy signup POST

| Field | Detail |
|---|---|
| Related module | AUTH / Gateway |
| Source location | `backend/gateway/main.py:86` and `backend/gateway/main.py:91`; `backend/auth/router.py:16` |
| Reason it may be an issue | The gateway defines a dedicated `POST /auth/login`, while the catch-all Auth route permits GET/PUT/PATCH/DELETE/OPTIONS/HEAD but not POST. The Auth service defines `POST /auth/signup`, so `POST http://localhost:8000/auth/signup` has no matching gateway route. |
| Possible user impact | Signup cannot be consumed through the same gateway base URL used by the frontend/API clients. |
| Suggested verification steps | Start Gateway/Auth/User; POST a valid signup body to gateway `/auth/signup`; compare with direct Auth-service `/auth/signup`; record status/body and whether profile/account rows are created. |
| Expected behavior | TBD – Requires confirmation whether signup must be publicly exposed through the gateway. If yes, the gateway should forward it consistently. |
| Current status | Not Confirmed |
| Classification | Potential Issue Identified Through Code Review |

## PI-USER-001 — Duplicate function definition removes user-not-found handling

| Field | Detail |
|---|---|
| Related module | USER |
| Source location | `backend/users/service.py:163` and `backend/users/service.py:188`; `backend/users/router.py:33` |
| Reason it may be an issue | `get_user_by_username_service` is defined twice. The later definition overwrites the earlier implementation and returns repository output directly without raising 404. A missing username may therefore return `None` into a `UserPublic` response model and produce a response-validation/server error. |
| Possible user impact | Searching for an unknown student may return an unexpected 500-class response instead of 404, reducing UI error accuracy. |
| Suggested verification steps | Call authenticated `GET /user/by-username/{unknown}` through gateway and direct service; record status/body/logs. |
| Expected behavior | A missing user should return 404 `User not found`, matching the earlier active-intent design and other lookup methods. |
| Current status | Confirmed through `TC-USER-003` |
| Classification | Confirmed defect — `DEF-USER-001` |

## PI-FEE-001 — Another-student invoice endpoint is not authenticated

| Field | Detail |
|---|---|
| Related module | FEE / Access control |
| Source location | `backend/studentfee/router.py:45` |
| Reason it may be an issue | `GET /studentfee/invoice/{username}` has no `Depends(get_current_user)`, unlike own invoice, pay, and semester APIs. The path value is passed directly as a student identifier. |
| Possible user impact | Anyone who knows/guesses a student UUID may retrieve invoice items and tuition amounts. |
| Suggested verification steps | Request a known invoice without Authorization, then with invalid and valid tokens; compare responses. Confirm intended privacy policy with the owner. |
| Expected behavior | TBD – Requires confirmation. Tuition invoice visibility is expected to require an explicit access policy. |
| Current status | Not Confirmed |
| Classification | Potential Issue Identified Through Code Review |

## PI-PAY-001 — Intent actions do not verify payer ownership

| Field | Detail |
|---|---|
| Related module | PAY / Access control |
| Source location | `backend/payment/router.py:29`, `backend/payment/router.py:64`, `backend/payment/router.py:82`; `backend/payment/service.py:257`, `backend/payment/service.py:304` |
| Reason it may be an issue | Routes authenticate the caller but send/confirm/cancel logic looks up intent by ID and does not compare `intent.payer_user_id` with JWT `sub`. |
| Possible user impact | An authenticated user who obtains another intent ID may send an OTP, attempt confirmation, or cancel that intent. |
| Suggested verification steps | Create an intent as User A; authenticate as User B; call send-otp, confirm (with controlled OTP), and cancel using A's ID; validate state/balance. Do not use production data. |
| Expected behavior | Only the intent owner or an explicitly authorized service should mutate an intent; unauthorized callers should receive 403 without state change. Final policy is TBD. |
| Current status | Observed through `TC-PAY-015`; defect classification blocked pending ownership-policy confirmation |
| Classification | Potential Issue Identified Through Code Review |

## PI-HIST-001 — History endpoint does not verify requested student ownership

| Field | Detail |
|---|---|
| Related module | HIST / Access control |
| Source location | `backend/payment/router.py:100`; `backend/payment/repo.py:210` |
| Reason it may be an issue | Any authenticated caller supplies `student_id`; code does not compare it with JWT `sub` or enforce a documented pay-on-behalf visibility policy. |
| Possible user impact | Transaction amounts and participant usernames for other students may be disclosed. |
| Suggested verification steps | Authenticate as User A and request history for User B with a valid semester; compare with intended policy and verify response fields. |
| Expected behavior | TBD – Requires confirmation. Access should be limited according to an explicit privacy rule. |
| Current status | Observed through `TC-HIST-005`; defect classification blocked pending history-visibility policy confirmation |
| Classification | Potential Issue Identified Through Code Review |

## PI-PAY-002 — Active OTP resend guard falls through to resend

| Field | Detail |
|---|---|
| Related module | PAY / OTP |
| Source location | `backend/payment/service.py:269-292` |
| Reason it may be an issue | When an OTP is still valid, code raises `ValueError` at line 286 inside a broad `try`. The adjacent `except Exception` catches it and executes the fallback that sends and stores a new OTP. |
| Possible user impact | Repeated resend calls may invalidate a still-valid OTP, increase attempts, and send unexpected email instead of returning the intended wait message. |
| Suggested verification steps | Create intent; send OTP; immediately call send-otp again; inspect status/body, email count, `otp_code`, expiry, and `otp_attempts`. |
| Expected behavior | Based on the explicit message, resend while current OTP is valid should be rejected and should not change/send another OTP. |
| Current status | Confirmed through `TC-PAY-007` |
| Classification | Confirmed defect — `DEF-PAY-002` |

## PI-PAY-003 — OTP lifetime differs between code and email

| Field | Detail |
|---|---|
| Related module | PAY / UI / Email |
| Source location | `backend/payment/service.py:264-266`; `backend/payment/mailer.py:13` and email template; `frontend/src/pages/Home/Home.jsx:56` |
| Reason it may be an issue | Active service and UI use 180 seconds, while both plain-text and HTML email state five minutes. |
| Possible user impact | A user may reasonably enter a code between minute 3 and minute 5 based on email instructions, but the server can reject it as expired. |
| Suggested verification steps | Send OTP; verify stored expiry and UI timer; attempt confirmation just after 180 seconds; compare email wording. |
| Expected behavior | OTP must expire after 180 seconds, and the UI and all email content must communicate that same duration. |
| Current status | Not Confirmed |
| Classification | Potential Issue Identified Through Code Review |

## PI-HIST-002 — Semester check may not filter returned intents/payments

| Field | Detail |
|---|---|
| Related module | HIST |
| Source location | `backend/payment/repo.py:215-247` |
| Reason it may be an issue | Code first verifies an invoice for the requested student/semester, but then queries all intents where the student is payer or beneficiary without constraining `invoice_id` to the invoice(s) from that semester. |
| Possible user impact | Selecting one semester may show completed payments from other semesters. |
| Suggested verification steps | Prepare one student with payments in two semesters; request each semester separately; compare returned intent invoice relationships and UI rows. |
| Expected behavior | A semester-specific history endpoint should return only payments associated with that semester, unless product requirements state otherwise. |
| Current status | Not Confirmed |
| Classification | Potential Issue Identified Through Code Review |

## PI-PAY-004 — Debit may not be compensated after later cross-service failure

| Field | Detail |
|---|---|
| Related module | PAY / Data integrity |
| Source location | `backend/payment/service.py:347-413` |
| Reason it may be an issue | The payer is debited before invoice update, intent confirmation, and payment upsert. The catch block marks the intent failed but does not deposit/refund the deducted amount if a later step fails. |
| Possible user impact | Balance can decrease while invoice remains unpaid and no confirmed payment/receipt exists. |
| Suggested verification steps | In an isolated environment, force Student Fee update or payment upsert to fail after a successful debit; compare all before/after records. |
| Expected behavior | The operation should be atomic or use a documented compensation/reconciliation mechanism so financial state remains consistent. |
| Current status | Not Confirmed |
| Classification | Potential Issue Identified Through Code Review |

## PI-UI-001 — Frontend calls a payment endpoint that does not exist

| Field | Detail |
|---|---|
| Related module | UI / PAY |
| Source location | `frontend/src/services/paymentService.js:22`; `frontend/src/pages/Home/Home.jsx:185`; no matching route in `backend/payment/router.py` |
| Reason it may be an issue | `getCurrentIntent` calls `GET /payment/intents/current`, but the backend defines no such endpoint. Home calls it whenever invoice/user data loads and catches the failure as “no current intent.” |
| Possible user impact | An unnecessary failing request occurs on page load, and a real active intent cannot be restored after refresh. |
| Suggested verification steps | Open Home with valid data; inspect network request/status; create an open intent, refresh, and observe whether it is restored. |
| Expected behavior | Either implement and specify the endpoint or remove the call and define the intended refresh/recovery behavior. |
| Current status | Not Confirmed |
| Classification | Potential Issue Identified Through Code Review |

## PI-FEE-002 — UI treats the first unsorted semester as current

| Field | Detail |
|---|---|
| Related module | UI / FEE |
| Source location | `backend/studentfee/repo.py:43`; `frontend/src/pages/Home/Home.jsx:129`, `292`, `398`, `831` |
| Reason it may be an issue | Semester repository query has no ordering, while the UI selects/displays `semesters[0]` as default/current and uses it for other-student payment/history. |
| Possible user impact | A non-current semester may be displayed or passed to history/payment-related calls depending on database return order. |
| Suggested verification steps | Store multiple semesters in non-chronological insertion order; compare UI default/current label with date-range current semester. |
| Expected behavior | Current semester should be selected using an explicit current flag/date rule or deterministic ordering. |
| Current status | Not Confirmed |
| Classification | Potential Issue Identified Through Code Review |

## Review outcome

Two code-review candidates were reproduced through execution and promoted to `DEF-USER-001` and `DEF-PAY-002`. Two access-control candidates were observed but remain blocked pending explicit ownership/privacy policy. The remaining candidates are not confirmed by the recorded test results.
