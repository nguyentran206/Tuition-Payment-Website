# DEF-PAY-002 — Pre-expiry OTP resend is accepted and replaces the active OTP

| Field | Value |
|---|---|
| Defect ID | DEF-PAY-002 |
| Description | Resending before the active OTP expires succeeds instead of enforcing the intended wait guard. |
| Environment | Local environment; executed 2026-07-20 to 2026-07-23 using Postman and a controlled mailbox. Commit/build and client version were not recorded. |
| Module | PAY |
| Preconditions | An intent has an active unexpired OTP and the test mailbox is accessible. |
| Steps to Reproduce | 1. Send the first OTP.<br>2. Before expiry, call the send-OTP endpoint again for the same intent.<br>3. Inspect HTTP response, email count, OTP fields, expiry, and `otp_attempts`.<br>4. After expiry, repeat once for comparison. |
| Test Data | Synthetic payment intent with controlled OTP lifecycle. |
| Expected Result | A pre-expiry resend is rejected without changing OTP data or sending email; a post-expiry resend creates a new OTP and increments attempts. |
| Actual Result | The pre-expiry resend returned HTTP 200, sent a new OTP email, replaced OTP data, and incremented `otp_attempts`. The post-expiry resend behaved as expected. |
| Severity | Medium |
| Priority | P1 |
| Reproducibility | Reproduced during the documented pre-expiry execution; repeat count was not recorded. |
| Evidence | [TC-PAY-007 evidence 1](../images/TC-PAY-007-1.png), [evidence 2](../images/TC-PAY-007-2.png), [evidence 3](../images/TC-PAY-007-3.png). Live OTP values must remain redacted. |
| Related Test Case | `TC-PAY-007` |
| Status | Open |
| Assigned To | TBD |
| Reported Date | 2026-07-23 |
| Retest Result | Not Retested |
| Notes | Confirms the behavior predicted by `PI-PAY-002`. |
