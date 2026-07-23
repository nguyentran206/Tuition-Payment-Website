# DEF-FEE-001 — Invalid another-student invoice paths return HTTP 500

| Field | Value |
|---|---|
| Defect ID | DEF-FEE-001 |
| Description | The another-student invoice endpoint returns an uncontrolled server error for invalid or not-found path values. |
| Environment | Local environment; executed 2026-07-20 to 2026-07-23 using Postman. Commit/build and client version were not recorded. |
| Module | FEE |
| Preconditions | Services are running, the caller is authenticated, and a current semester exists. |
| Steps to Reproduce | 1. Request `/studentfee/invoice/{value}` using an unknown UUID.<br>2. Repeat using a username string instead of a UUID.<br>3. Repeat with an empty-path request.<br>4. Record each response. |
| Test Data | Synthetic unknown UUID, username string, and empty path. |
| Expected Result | A missing invoice returns HTTP 404; malformed or unmatched input returns a controlled 4xx response. |
| Actual Result | All three variants returned HTTP 500. |
| Severity | Medium |
| Priority | P1 |
| Reproducibility | Observed for every documented variant; repeat count was not recorded. |
| Evidence | [Invalid/not-found variant 1](../images/TC-FEE-007-1.png), [variant 2](../images/TC-FEE-007-2.png), [variant 3](../images/TC-FEE-007-3.png) |
| Related Test Case | `TC-FEE-007` |
| Status | Open |
| Assigned To | TBD |
| Reported Date | 2026-07-23 |
| Retest Result | Not Retested |
| Notes | Capture sanitized response bodies and service logs during triage to distinguish route and repository error paths. |
