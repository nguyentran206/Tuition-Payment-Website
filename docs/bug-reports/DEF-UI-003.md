# DEF-UI-003 — Invoice remains stale after changing semester

| Field | Value |
|---|---|
| Defect ID | DEF-UI-003 |
| Description | Home updates the selected semester's course count but continues displaying invoice information from the previously selected semester. |
| Environment | Local environment; executed 2026-07-20 to 2026-07-23 using Chrome. Chrome version and commit/build were not recorded. |
| Module | UI |
| Preconditions | The user is logged in and has distinguishable invoice/course data for multiple semesters. |
| Steps to Reproduce | 1. Open Home and record the current semester invoice.<br>2. Select another semester.<br>3. Compare course count and displayed invoice with the selected semester's API data. |
| Test Data | Synthetic user with invoice data for multiple semesters. |
| Expected Result | Course, invoice, and history displays refresh together and match the selected semester. |
| Actual Result | The course count updated, but the invoice remained from the previous semester. |
| Severity | Medium |
| Priority | P1 |
| Reproducibility | Reproduced during the documented UI execution; repeat count was not recorded. |
| Evidence | [TC-UI-003 evidence 1](../images/TC-UI-003-1.png), [evidence 2](../images/TC-UI-003-2.png) |
| Related Test Case | `TC-UI-003` |
| Status | Open |
| Assigned To | TBD |
| Reported Date | 2026-07-23 |
| Retest Result | Not Retested |
| Notes | Incorrect invoice display can mislead users about the amount/status associated with the selected semester. |
