# DEF-PAY-001 — Unknown student or semester causes intent creation HTTP 500

| Field | Value |
|---|---|
| Defect ID | DEF-PAY-001 |
| Description | Payment-intent creation handles normalization and schema validation correctly but fails with HTTP 500 when referenced student or semester data does not exist. |
| Environment | Local environment; executed 2026-07-20 to 2026-07-23 using Postman. Commit/build and client version were not recorded. |
| Module | PAY |
| Preconditions | Services are running and the payer is authenticated. |
| Steps to Reproduce | 1. POST `/payment/intents` with an unknown student ID.<br>2. Repeat with an unknown semester ID in the self-payment flow.<br>3. Verify that no unintended intent is created.<br>4. Record each response. |
| Test Data | Synthetic unknown student and semester identifiers. |
| Expected Result | Missing upstream resources return HTTP 404 or another controlled 4xx response; no intent is created. |
| Actual Result | Both the unknown-student and unknown-semester variants returned HTTP 500. Empty, whitespace, and literal `string` normalization passed; incorrect JSON types returned HTTP 422. |
| Severity | Medium |
| Priority | P1 |
| Reproducibility | Observed for both missing-resource variants; repeat count was not recorded. |
| Evidence | [Variant 1](../images/TC-PAY-004-1.png), [variant 2](../images/TC-PAY-004-2.png), [variant 3](../images/TC-PAY-004-3.png), [variant 4](../images/TC-PAY-004-4.png) |
| Related Test Case | `TC-PAY-004` |
| Status | Open |
| Assigned To | TBD |
| Reported Date | 2026-07-23 |
| Retest Result | Not Retested |
| Notes | Triage should verify upstream error translation and confirm no payment-intent row is persisted after either failure. |
