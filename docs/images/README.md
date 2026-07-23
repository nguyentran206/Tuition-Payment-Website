# Test Execution Evidence

This directory contains **121 PNG screenshots covering 50 of 53 designed test cases**. Evidence was captured during local manual execution from 2026-07-20 through 2026-07-23 using Postman for API cases and Chrome for UI cases.

The screenshots support the written Actual Result; they do not replace the test steps, expected results, database checks, or defect reports. Test status remains authoritative in [the manual test cases](../test-cases/test-cases.md).

## Coverage summary

| Module | Designed cases | Cases with screenshots |
|---|---:|---:|
| AUTH | 10 | 10 |
| USER | 8 | 8 |
| FEE | 8 | 7 |
| PAY | 15 | 15 |
| HIST | 5 | 4 |
| UI | 7 | 6 |
| **Total** | **53** | **50** |

## AUTH evidence

| Test case | Status | Scenario | Screenshots | Notes |
|---|---|---|---|---|
| `TC-AUTH-001` | Passed | Login with valid credentials | [View](TC-AUTH-001.png) | Execution evidence. |
| `TC-AUTH-002` | Passed | Login with incorrect password | [View](TC-AUTH-002.png) | Execution evidence. |
| `TC-AUTH-003` | Passed | Login with unknown username | [View](TC-AUTH-003.png) | Execution evidence. |
| `TC-AUTH-004` | Passed | Login with an empty required field | [1](TC-AUTH-004-1.png) · [2](TC-AUTH-004-2.png) · [3](TC-AUTH-004-3.png) · [4](TC-AUTH-004-4.png) · [5](TC-AUTH-004-5.png) | Execution evidence. |
| `TC-AUTH-005` | Passed | Verify a valid token | [View](TC-AUTH-005.png) | Execution evidence. |
| `TC-AUTH-006` | Passed | Access protected API without token | [1](TC-AUTH-006-1.png) · [2](TC-AUTH-006-2.png) · [3](TC-AUTH-006-3.png) | Execution evidence. |
| `TC-AUTH-007` | Passed | Access protected API with invalid/expired token | [1](TC-AUTH-007-1.png) · [2](TC-AUTH-007-2.png) | Execution evidence. |
| `TC-AUTH-008` | Passed | Direct-service signup success | [View](TC-AUTH-008.png) | Execution evidence. |
| `TC-AUTH-009` | Passed | Signup duplicate username and invalid email | [1](TC-AUTH-009-1.png) · [2](TC-AUTH-009-2.png) | Execution evidence. |
| `TC-AUTH-010` | Passed | Logout and protected Home redirect | [1](TC-AUTH-010-1.png) · [2](TC-AUTH-010-2.png) | Execution evidence. |

## USER evidence

| Test case | Status | Scenario | Screenshots | Notes |
|---|---|---|---|---|
| `TC-USER-001` | Passed | Retrieve current profile | [View](TC-USER-001.png) | Execution evidence. |
| `TC-USER-002` | Passed | Retrieve users by ID and username | [1](TC-USER-002-1.png) · [2](TC-USER-002-2.png) | Execution evidence. |
| `TC-USER-003` | Failed | Unknown or malformed user identifier | [1](TC-USER-003-1.png) · [2](TC-USER-003-2.png) · [3](TC-USER-003-3.png) | Linked from the related formal defect report. |
| `TC-USER-004` | Passed | Create user validation | [1](TC-USER-004-1.png) · [2](TC-USER-004-2.png) · [3](TC-USER-004-3.png) · [4](TC-USER-004-4.png) · [5](TC-USER-004-5.png) | Execution evidence. |
| `TC-USER-005` | Passed | Deposit valid amount | [1](TC-USER-005-1.png) · [2](TC-USER-005-2.png) | Execution evidence. |
| `TC-USER-006` | Passed | Deposit/debit amount boundaries and types | [1](TC-USER-006-1.png) · [2](TC-USER-006-2.png) · [3](TC-USER-006-3.png) · [4](TC-USER-006-4.png) · [5](TC-USER-006-5.png) · [6](TC-USER-006-6.png) · [7](TC-USER-006-7.png) · [8](TC-USER-006-8.png) | Execution evidence. |
| `TC-USER-007` | Passed | Debit with exact and insufficient balance | [1](TC-USER-007-1.png) · [2](TC-USER-007-2.png) · [3](TC-USER-007-3.png) | Execution evidence. |
| `TC-USER-008` | Passed | Concurrent balance compare-and-update | [View](TC-USER-008.png) | Execution evidence. |

## FEE evidence

| Test case | Status | Scenario | Screenshots | Notes |
|---|---|---|---|---|
| `TC-FEE-001` | Passed | List semesters | [View](TC-FEE-001.png) | Execution evidence. |
| `TC-FEE-002` | Not Run | Empty semester list | Not available | No execution evidence because the required dataset was unavailable or destructive to prepare. |
| `TC-FEE-003` | Passed | Retrieve own invoice for selected semester | [View](TC-FEE-003.png) | Execution evidence. |
| `TC-FEE-004` | Passed | Retrieve own current-semester invoice | [View](TC-FEE-004.png) | Execution evidence. |
| `TC-FEE-005` | Passed | Missing current semester or invoice | [1](TC-FEE-005-1.png) · [2](TC-FEE-005-2.png) | Execution evidence. |
| `TC-FEE-006` | Passed | Retrieve another student's current invoice | [View](TC-FEE-006.png) | Execution evidence. |
| `TC-FEE-007` | Failed | Another-student invoice with invalid/not-found ID | [1](TC-FEE-007-1.png) · [2](TC-FEE-007-2.png) · [3](TC-FEE-007-3.png) | Linked from the related formal defect report. |
| `TC-FEE-008` | Passed | Mark invoice paid | [1](TC-FEE-008-1.png) · [2](TC-FEE-008-2.png) · [3](TC-FEE-008-3.png) | Execution evidence. |

## PAY evidence

| Test case | Status | Scenario | Screenshots | Notes |
|---|---|---|---|---|
| `TC-PAY-001` | Passed | Create self-payment intent | [View](TC-PAY-001.png) | Execution evidence. |
| `TC-PAY-002` | Passed | Create intent for another student | [View](TC-PAY-002.png) | Execution evidence. |
| `TC-PAY-003` | Passed | Reject paid or non-positive invoice | [View](TC-PAY-003.png) | Execution evidence. |
| `TC-PAY-004` | Failed | Intent input normalization and not-found data | [1](TC-PAY-004-1.png) · [2](TC-PAY-004-2.png) · [3](TC-PAY-004-3.png) · [4](TC-PAY-004-4.png) | Linked from the related formal defect report. |
| `TC-PAY-005` | Passed | Duplicate open intent submission | [1](TC-PAY-005-1.png) · [2](TC-PAY-005-2.png) | Execution evidence. |
| `TC-PAY-006` | Passed | Send first OTP | [1](TC-PAY-006-1.png) · [2](TC-PAY-006-2.png) · [3](TC-PAY-006-3.png) · [4](TC-PAY-006-4.png) | Execution evidence. |
| `TC-PAY-007` | Failed | Resend before and after expiry | [1](TC-PAY-007-1.png) · [2](TC-PAY-007-2.png) · [3](TC-PAY-007-3.png) | Linked from the related formal defect report. |
| `TC-PAY-008` | Blocked | Send OTP for invalid resource or state | [1](TC-PAY-008-1.png) · [2](TC-PAY-008-2.png) · [3](TC-PAY-008-3.png) | Observed behavior is documented; defect classification awaits policy clarification. |
| `TC-PAY-009` | Passed | Confirm request-body validation | [1](TC-PAY-009-1.png) · [2](TC-PAY-009-2.png) · [3](TC-PAY-009-3.png) · [4](TC-PAY-009-4.png) · [5](TC-PAY-009-5.png) · [6](TC-PAY-009-6.png) · [7](TC-PAY-009-7.png) · [8](TC-PAY-009-8.png) | Execution evidence. |
| `TC-PAY-010` | Passed | Confirm with correct OTP | [1](TC-PAY-010-1.png) · [2](TC-PAY-010-2.png) · [3](TC-PAY-010-3.png) · [4](TC-PAY-010-4.png) · [5](TC-PAY-010-5.png) | Execution evidence. |
| `TC-PAY-011` | Passed | Confirm incorrect or expired OTP | [1](TC-PAY-011-1.png) · [2](TC-PAY-011-2.png) | Execution evidence. |
| `TC-PAY-012` | Passed | Confirm invalid intent state and duplicate confirmation | [1](TC-PAY-012-1.png) · [2](TC-PAY-012-2.png) · [3](TC-PAY-012-3.png) | Execution evidence. |
| `TC-PAY-013` | Passed | Concurrent confirmation | [View](TC-PAY-013.png) | Execution evidence. |
| `TC-PAY-014` | Passed | Cancel intent and repeat cancel | [View](TC-PAY-014.png) | Execution evidence. |
| `TC-PAY-015` | Blocked | Cross-user forbidden intent actions | [View](TC-PAY-015.png) | Observed behavior is documented; defect classification awaits policy clarification. |

## HIST evidence

| Test case | Status | Scenario | Screenshots | Notes |
|---|---|---|---|---|
| `TC-HIST-001` | Passed | Retrieve completed self-related history | [View](TC-HIST-001.png) | Execution evidence. |
| `TC-HIST-002` | Passed | Empty history | [View](TC-HIST-002.png) | Execution evidence. |
| `TC-HIST-003` | Passed | Invalid history parameters and missing auth | [1](TC-HIST-003-1.png) · [2](TC-HIST-003-2.png) · [3](TC-HIST-003-3.png) · [4](TC-HIST-003-4.png) | Execution evidence. |
| `TC-HIST-004` | Not Run | Semester isolation | Not available | No execution evidence because the required dataset was unavailable or destructive to prepare. |
| `TC-HIST-005` | Blocked | Cross-user history authorization | [View](TC-HIST-005.png) | Observed behavior is documented; defect classification awaits policy clarification. |

## UI evidence

| Test case | Status | Scenario | Screenshots | Notes |
|---|---|---|---|---|
| `TC-UI-001` | Passed | Login form validation and password visibility | [1](TC-UI-001-1.png) · [2](TC-UI-001-2.png) · [3](TC-UI-001-3.png) | Execution evidence. |
| `TC-UI-002` | Passed | Successful and failed login navigation | [View](TC-UI-002.png) | Execution evidence. |
| `TC-UI-003` | Failed | Home data display and formatting | [1](TC-UI-003-1.png) · [2](TC-UI-003-2.png) | Linked from the related formal defect report. |
| `TC-UI-004` | Passed | Terms gate and self/other lookup flows | [1](TC-UI-004-1.png) · [2](TC-UI-004-2.png) · [3](TC-UI-004-3.png) · [4](TC-UI-004-4.png) | Execution evidence. |
| `TC-UI-005` | Passed | Insufficient balance and top-up validation | [1](TC-UI-005-1.png) · [2](TC-UI-005-2.png) · [3](TC-UI-005-3.png) · [4](TC-UI-005-4.png) · [5](TC-UI-005-5.png) · [6](TC-UI-005-6.png) | Execution evidence. |
| `TC-UI-006` | Passed | OTP input, timer, resend, and cancel | [1](TC-UI-006-1.png) · [2](TC-UI-006-2.png) | Execution evidence. |
| `TC-UI-007` | Passed | End-to-end payment success and recovery on refresh | Not available | No screenshot was committed for this executed case. |

## Evidence handling rules

- Redact passwords, full JWTs, OTP values, service-role keys, SMTP credentials, private URLs, cookies, and real personal/student data before committing evidence.
- Use synthetic accounts and identifiers wherever possible.
- Keep the test case ID at the beginning of each filename. Multiple screenshots use numeric suffixes such as `TC-PAY-010-1.png` and `TC-PAY-010-2.png`.
- Do not edit a screenshot in a way that changes the observed behavior.
- Keep image sizes reasonable. Add new screenshots to the corresponding row in this index.
- A screenshot is supporting evidence, not a substitute for written reproduction steps and exact Actual Result.
