# Defect Reports

## Confirmed defects

| Defect | Related case | Status | Summary |
|---|---|---|---|
| [DEF-USER-001](DEF-USER-001.md) | `TC-USER-003` | Open | Unknown or malformed user identifiers return HTTP 500. |
| [DEF-FEE-001](DEF-FEE-001.md) | `TC-FEE-007` | Open | Invalid another-student invoice paths return HTTP 500. |
| [DEF-PAY-001](DEF-PAY-001.md) | `TC-PAY-004` | Open | Unknown student or semester causes intent creation HTTP 500. |
| [DEF-PAY-002](DEF-PAY-002.md) | `TC-PAY-007` | Open | Pre-expiry OTP resend is accepted and replaces the active OTP. |
| [DEF-UI-003](DEF-UI-003.md) | `TC-UI-003` | Open | Invoice remains stale after changing semester. |

## Blocked observations

The following executed cases have observed behavior but remain Blocked with `Defect ID = N/A` until the related policy is confirmed:

- `TC-PAY-008`: OTP can be sent for `confirmed` and `failed` intents.
- `TC-PAY-015`: an authenticated user can mutate another user's payment intent; related to `PI-PAY-001`.
- `TC-HIST-005`: an authenticated user can view another user's payment history; related to `PI-HIST-001`.

## Supporting documents

- [Potential issues identified through code review](potential-issues.md)
- [Defect report template](defect-report-template.md)
- [Manual execution summary](../test-reports/test-summary-report.md)
