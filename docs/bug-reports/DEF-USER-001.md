# DEF-USER-001 — Unknown or malformed user identifiers return HTTP 500

| Field | Value |
|---|---|
| Defect ID | DEF-USER-001 |
| Description | User lookup fails with an uncontrolled server error for unknown and malformed identifiers. |
| Environment | Local environment; executed 2026-07-20 to 2026-07-23 using Postman. Commit/build and client version were not recorded. |
| Module | USER |
| Preconditions | Services are running and the caller is authenticated. |
| Steps to Reproduce | 1. Call `GET /user/by-id/{id}` with an unknown valid UUID.<br>2. Repeat with a malformed ID.<br>3. Call `GET /user/by-username/{username}` with an unknown username.<br>4. Record each response. |
| Test Data | Synthetic unknown UUID, malformed ID, and unknown username. |
| Expected Result | Unknown resources return HTTP 404 `User not found`; malformed identifiers return a controlled 4xx response. |
| Actual Result | All three variants returned HTTP 500. |
| Severity | Medium |
| Priority | P1 |
| Reproducibility | Observed for every documented variant; repeat count was not recorded. |
| Evidence | [TC-USER-003 evidence 1](../images/TC-USER-003-1.png), [evidence 2](../images/TC-USER-003-2.png), [evidence 3](../images/TC-USER-003-3.png) |
| Related Test Case | `TC-USER-003` |
| Status | Open |
| Assigned To | TBD |
| Reported Date | 2026-07-23 |
| Retest Result | Not Retested |
| Notes | The unknown-username variant reproduces `PI-USER-001`. Sanitized response bodies/logs should be attached during triage if available. |
