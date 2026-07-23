# Test Summary Report — Manual Execution

## 1. Purpose

This report summarizes manual execution of the Tuition Payment Website test suite from 2026-07-20 through 2026-07-23.

## 2. Testing scope

Planned coverage includes Auth, User, Student Fee, Payment, Payment History, and React UI modules. It includes functional, API, UI, negative, boundary, validation, access-control, state-transition, basic regression, and database validation checks described in the test plan.

## 3. Test environment

Execution used the local React/Vite frontend, FastAPI gateway and services, local project configuration, test database data, and a controlled email workflow. API cases were executed with Postman and UI cases with Chrome. The Chrome version and tested commit/build were not recorded.

The repository contains 121 PNG screenshots covering 50 of 53 designed test cases. Files use the test case ID, for example `TC-AUTH-001`; multiple artifacts use numeric suffixes such as `TC-AUTH-004-1` and `TC-AUTH-004-2`. See the [test evidence index](../images/README.md).

## 4. Test execution status

**Execution Status: Completed with exceptions**

## 5. Execution metrics

| Metric | Value |
|---|---:|
| Planned test case count | 53 |
| Executed | 51 |
| Passed | 43 |
| Failed | 5 |
| Blocked | 3 |
| Not Run | 2 |
| Confirmed defects | 5 |
| Potential issues from code review | 11 |

`Executed` includes Passed, Failed, and Blocked cases. The two Not Run cases were intentionally omitted because their required data was unavailable or creating it would require deleting existing test data. Potential issues are excluded from the confirmed-defect count unless promoted to a formal `DEF-*` report.

## 6. Module status

| Module | Designed | Passed | Failed | Blocked | Not Run |
|---|---:|---:|---:|---:|---:|
| AUTH | 10 | 10 | 0 | 0 | 0 |
| USER | 8 | 7 | 1 | 0 | 0 |
| FEE | 8 | 6 | 1 | 0 | 1 |
| PAY | 15 | 11 | 2 | 2 | 0 |
| HIST | 5 | 3 | 0 | 1 | 1 |
| UI | 7 | 6 | 1 | 0 | 0 |
| **Total** | **53** | **43** | **5** | **3** | **2** |

## 7. Potential issues from code review

Eleven code-review hypotheses remain listed in `docs/bug-reports/potential-issues.md`. Execution confirmed `PI-USER-001` and `PI-PAY-002`, which were promoted to `DEF-USER-001` and `DEF-PAY-002`. `PI-PAY-001` and `PI-HIST-001` were observed, but their related test cases remain Blocked until ownership/privacy policy is confirmed.

Five formal defects are currently Open: `DEF-USER-001`, `DEF-FEE-001`, `DEF-PAY-001`, `DEF-PAY-002`, and `DEF-UI-003`.

## 8. Major risks

- Cross-service payment updates are not atomic and may leave inconsistent financial state on partial failure.
- Resource-ownership rules are absent or unclear for sensitive endpoints.
- Database DDL, constraints, and RLS policies are unavailable.
- Gateway routes and frontend calls do not fully match downstream APIs.
- Some destructive or multi-semester datasets were unavailable, leaving two cases Not Run.
- OTP requirements conflict between application behavior and email text.

## 9. Known limitations

- No automated test framework or CI test result exists in the repository.
- Chrome version and tested commit/build were not recorded.
- Screenshot coverage is available for 50 of 53 case IDs. `TC-FEE-002`, `TC-HIST-004`, and `TC-UI-007` have no committed screenshot.
- Expected outcomes for open authorization/business questions require stakeholder confirmation.
- Three cases remain Blocked and two remain Not Run.

## 10. Recommended next steps

1. Triage and fix the five Open defects, then retest them on a recorded commit/build.
2. Confirm ownership/privacy rules for terminal-state OTP actions, cross-user intent mutation, and cross-user history visibility.
3. Prepare disposable empty-semester and two-semester history datasets to execute the two Not Run cases.
4. Record the Chrome version, commit SHA, timestamps, and any non-image log locations in the next execution cycle.
5. Re-run affected USER, FEE, PAY, HIST, and UI regression cases after fixes or policy decisions.

## 11. Conclusion

Manual execution completed for 51 of 53 designed cases. Forty-three passed, five failed, and three were blocked; two cases were not run because their datasets were unavailable or destructive to prepare. The current result does not support an unconditional release recommendation until the five defects are triaged and the blocked access-control/state policies are resolved.
