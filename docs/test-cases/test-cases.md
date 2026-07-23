# Manual Test Cases

## Execution rules

- These cases were designed from active repository code and executed locally from 2026-07-20 through 2026-07-23, except cases explicitly marked `Not Run`.
- Execution used synthetic/local test data; cases requiring destructive or unavailable datasets remain explicitly marked `Not Run`.
- API execution used Postman; UI execution used Chrome. Sanitized screenshots are indexed in [Test Execution Evidence](../images/README.md) using test-case IDs and numeric suffixes for multiple artifacts.
- Do not commit passwords, full JWTs, OTPs, service keys, or real student data.
- `Passed` means every documented step and data variant matched the Expected Result. `Blocked` records observed behavior that cannot be classified until the related requirement/policy is confirmed.

## AUTH — Authentication (10 cases)

### TC-AUTH-001 — Login with valid credentials

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-001, REQ-AUTH-004 |
| Module | AUTH |
| Priority | High |
| Test Type | API / Functional |
| Preconditions | Gateway, Auth service, and database are available; active synthetic account exists. |
| Test Data | `username=<valid_user>`, `password=<valid_password>` |
| Test Steps | 1. POST `/auth/login` through gateway with JSON credentials.<br>2. Record status/body.<br>3. Decode the JWT payload locally without exposing it.<br>4. Verify no password/hash is returned. |
| Expected Result | HTTP 200; body contains `message=Login successful`, matching username, non-empty `access_token`, and `token_type=bearer`; JWT contains `sub`, `username`, `iat`, `exp`, `iss=auth_svc`; expiry matches configured duration. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-002 — Login with incorrect password

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-002 |
| Module | AUTH |
| Priority | High |
| Test Type | API / Negative |
| Preconditions | Valid synthetic username exists. |
| Test Data | Valid username; incorrect password |
| Test Steps | 1. POST `/auth/login` with the valid username and wrong password.<br>2. Inspect response and verify no token is stored/returned. |
| Expected Result | HTTP 401 with `detail=Invalid credentials`; no access token. Account data and password hash remain unchanged. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-003 — Login with unknown username

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-002 |
| Module | AUTH |
| Priority | High |
| Test Type | API / Negative |
| Preconditions | Chosen username does not exist. |
| Test Data | `username=<unknown_user>`, any password |
| Test Steps | 1. POST `/auth/login`.<br>2. Compare response with TC-AUTH-002. |
| Expected Result | HTTP 401 with the same `Invalid credentials` detail and no token; response does not reveal whether the username exists. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-004 — Login with an empty required field

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-003 |
| Module | AUTH |
| Priority | High |
| Test Type | API / Validation / Negative |
| Preconditions | Gateway/Auth available. |
| Test Data | Variants: omit username; omit password; send `{}`; explicit `null` |
| Test Steps | 1. Submit each body variant to POST `/auth/login`.<br>2. Record status and validation locations. |
| Expected Result | Missing/null required fields return HTTP 422 with validation details; no token is issued. Empty strings are accepted by the schema and proceed to credential validation, expected 401 unless such an account exists. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-005 — Verify a valid token

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-004 |
| Module | AUTH |
| Priority | Medium |
| Test Type | API / Functional |
| Preconditions | Obtain a valid token from TC-AUTH-001. |
| Test Data | `Authorization: Bearer <valid_token>` |
| Test Steps | 1. GET `/auth/verify` through gateway.<br>2. Inspect `valid` and returned claims. |
| Expected Result | HTTP 200; `valid=true`; claims correspond to the authenticated synthetic user and configured expiry/issuer. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-006 — Access protected API without token

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-005 |
| Module | AUTH |
| Priority | High |
| Test Type | API / Unauthorized Access |
| Preconditions | User service is available. |
| Test Data | No Authorization header |
| Test Steps | 1. GET `/user/me` through gateway without Authorization.<br>2. Repeat on `/studentfee/semesters` and `/payment/payments/history/x/y`. |
| Expected Result | Each protected downstream API returns HTTP 401 and does not disclose protected data. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-007 — Access protected API with invalid/expired token

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-006 |
| Module | AUTH |
| Priority | High |
| Test Type | API / Unauthorized Access / Boundary |
| Preconditions | Have one malformed token and one deliberately short-lived expired test token. |
| Test Data | Malformed signature; expired `exp` |
| Test Steps | 1. GET `/user/me` with each token.<br>2. Repeat expired token on a Payment endpoint.<br>3. Verify no state change. |
| Expected Result | HTTP 401. Invalid signature returns invalid-token detail; expired Payment token returns `Token expired`; no data/state change. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-008 — Direct-service signup success

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-008 |
| Module | AUTH |
| Priority | Medium |
| Test Type | API / Functional / Database Validation |
| Preconditions | Call Auth service `:8001` directly; User service is reachable; unique synthetic username/email. |
| Test Data | Valid username, email, name, and password |
| Test Steps | 1. Snapshot absence of user/account rows.<br>2. POST direct `/auth/signup`.<br>3. Inspect response.<br>4. Verify User row then Auth row and hashed—not plaintext—password. |
| Expected Result | HTTP 200; `Signup successful`; one linked User row and one Auth row exist; stored hash differs from plaintext. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-009 — Signup duplicate username and invalid email

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-007, REQ-AUTH-008 |
| Module | AUTH |
| Priority | Medium |
| Test Type | API / Negative / Validation |
| Preconditions | Existing synthetic Auth username. |
| Test Data | Variant A: existing username with new email; Variant B: malformed email |
| Test Steps | 1. POST each variant directly to Auth `/auth/signup`.<br>2. Check response.<br>3. Verify no extra linked rows for rejected input. |
| Expected Result | Duplicate username: HTTP 400 `Username already exists`. Invalid email: HTTP 422. No duplicate Auth/User record is created. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-AUTH-010 — Logout and protected Home redirect

| Field | Value |
|---|---|
| Requirement ID | REQ-AUTH-009, REQ-UI-003 |
| Module | AUTH / UI |
| Priority | High |
| Test Type | UI / Functional |
| Preconditions | Logged in on Home with token in localStorage. |
| Test Data | Authenticated synthetic user |
| Test Steps | 1. Click logout.<br>2. Inspect URL and localStorage.<br>3. Navigate directly to `/home`. |
| Expected Result | Token is removed; browser navigates to `/login`; direct Home access without token redirects to `/login`. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-USER-001 — Retrieve current profile

| Field | Value |
|---|---|
| Requirement ID | REQ-USER-001 |
| Module | USER |
| Priority | High |
| Test Type | API / Functional |
| Preconditions | Valid token whose `sub` matches a User row. |
| Test Data | Valid bearer token |
| Test Steps | 1. GET `/user/me`.<br>2. Compare response with the User row and token subject. |
| Expected Result | HTTP 200; ID matches `sub`; username/email/name/balance match database; optional fields serialize without exposing internal data. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-USER-002 — Retrieve users by ID and username

| Field | Value |
|---|---|
| Requirement ID | REQ-USER-002 |
| Module | USER |
| Priority | Medium |
| Test Type | API / Functional |
| Preconditions | Authenticated caller; target synthetic user exists. |
| Test Data | Target UUID and username |
| Test Steps | 1. GET `/user/by-id/{id}`.<br>2. GET `/user/by-username/{username}`.<br>3. Compare both bodies. |
| Expected Result | Both return HTTP 200 and the same target profile; bearer token is required. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-USER-003 — Unknown or malformed user identifier

| Field | Value |
|---|---|
| Requirement ID | REQ-USER-002 |
| Module | USER |
| Priority | Medium |
| Test Type | API / Negative / Resource Not Found |
| Preconditions | Authenticated caller. |
| Test Data | Unknown valid UUID; malformed ID; unknown username |
| Test Steps | 1. Call by-id for each ID.<br>2. Call by-username for unknown username.<br>3. Record status/body/log and verify no change. |
| Expected Result | Unknown resources should return controlled HTTP 404 `User not found`; malformed database identifiers should produce a controlled 4xx response. Compare username result with PI-USER-001. |
| Actual Result | The unknown valid UUID, malformed ID, and unknown username variants all returned HTTP 500 instead of controlled 4xx responses. |
| Status | Failed |
| Defect ID | DEF-USER-001 |
| Notes | Failed due to uncontrolled HTTP 500 responses for all tested unknown/malformed user identifiers. See `DEF-USER-001`. |

### TC-USER-004 — Create user validation

| Field | Value |
|---|---|
| Requirement ID | REQ-USER-003 |
| Module | USER |
| Priority | Medium |
| Test Type | API / Validation / Negative |
| Preconditions | User service/gateway available. |
| Test Data | Missing username/email/name; empty string; malformed email; wrong data type |
| Test Steps | 1. POST `/user/create` for each variant.<br>2. Inspect status/detail.<br>3. Verify no row for rejected input. |
| Expected Result | Missing/null/type/invalid-email inputs return 422; empty required strings reach service and return 400 `Missing required fields`; no row is created. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-USER-005 — Deposit valid amount

| Field | Value |
|---|---|
| Requirement ID | REQ-USER-004, REQ-USER-006 |
| Module | USER |
| Priority | High |
| Test Type | API / Functional / Database Validation |
| Preconditions | Authenticated; target test user exists with known balance. |
| Test Data | `amount=100000.25` |
| Test Steps | 1. Record old balance.<br>2. POST `/user/{id}/deposit`.<br>3. Read user again and database row. |
| Expected Result | HTTP 200; `new_balance = old_balance + 100000.25`; exactly one compare-and-update succeeds. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-USER-006 — Deposit/debit amount boundaries and types

| Field | Value |
|---|---|
| Requirement ID | REQ-USER-004 |
| Module | USER |
| Priority | High |
| Test Type | API / Boundary / Validation |
| Preconditions | Authenticated; target test user exists. |
| Test Data | `0`, negative, `0.01`, more than 2 decimals, over 18 digits, alphabetic, null, missing |
| Test Steps | 1. Submit each amount to deposit and debit.<br>2. Record status/validation detail.<br>3. Verify balance after every rejected request. |
| Expected Result | `0.01` is schema-valid; zero/negative/precision/range/type/null/missing invalid values return 422; rejected inputs do not change balance. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-USER-007 — Debit with exact and insufficient balance

| Field | Value |
|---|---|
| Requirement ID | REQ-USER-005, REQ-USER-006 |
| Module | USER |
| Priority | High |
| Test Type | API / Boundary / Database Validation |
| Preconditions | Two isolated users with known balances. |
| Test Data | Variant A: amount equals balance; Variant B: amount exceeds balance by `0.01` |
| Test Steps | 1. Debit exact balance for A.<br>2. Verify new balance zero.<br>3. Debit excessive amount for B.<br>4. Verify B unchanged. |
| Expected Result | A: HTTP 200 and new balance `0.00`. B: HTTP 409 `Insufficient funds` and unchanged balance. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-USER-008 — Concurrent balance compare-and-update

| Field | Value |
|---|---|
| Requirement ID | REQ-USER-007 |
| Module | USER |
| Priority | High |
| Test Type | API / Concurrency / Database Validation |
| Preconditions | Isolated user with known sufficient balance; client capable of synchronized requests. |
| Test Data | Two simultaneous debit/deposit operations based on same initial balance |
| Test Steps | 1. Record old balance.<br>2. Send two simultaneous updates.<br>3. Record both responses.<br>4. Verify final balance matches successful operations only. |
| Expected Result | Only one debit operation is applied successfully. The other request is rejected. The final balance reflects exactly one successful debit and no lost update occurs. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-FEE-001 — List semesters

| Field | Value |
|---|---|
| Requirement ID | REQ-FEE-001 |
| Module | FEE |
| Priority | High |
| Test Type | API / Functional |
| Preconditions | Authenticated; semester rows exist. |
| Test Data | Valid token |
| Test Steps | 1. GET `/studentfee/semesters`.<br>2. Validate every response field/date against database. |
| Expected Result | HTTP 200 array; each item has semester ID/name, school year, start/end dates matching stored data. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-FEE-002 — Empty semester list

| Field | Value |
|---|---|
| Requirement ID | REQ-FEE-001 |
| Module | FEE |
| Priority | Medium |
| Test Type | API / Negative / Empty Data |
| Preconditions | Disposable dataset with no semester rows. |
| Test Data | Valid token |
| Test Steps | 1. GET `/studentfee/semesters`.<br>2. Inspect response and verify no unintended records. |
| Expected Result | HTTP 404 with `detail=No semesters found`. |
| Actual Result | Not executed because creating an empty-semester dataset would require deleting existing test data. |
| Status | Not Run |
| Defect ID | N/A |
| Notes | Not Run by tester decision to preserve the existing local semester data. |

### TC-FEE-003 — Retrieve own invoice for selected semester

| Field | Value |
|---|---|
| Requirement ID | REQ-FEE-002, REQ-FEE-004 |
| Module | FEE |
| Priority | High |
| Test Type | API / Functional / Database Validation |
| Preconditions | Authenticated student has invoice with multiple items for known semester. |
| Test Data | `semester_id=<known_semester>` |
| Test Steps | 1. GET `/studentfee/my-invoice?semester_id=...`.<br>2. Compare owner/semester/items/status.<br>3. Independently sum item amounts. |
| Expected Result | HTTP 200; invoice belongs to JWT subject and requested semester; all items returned; `total_amount` equals item sum. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-FEE-004 — Retrieve own current-semester invoice

| Field | Value |
|---|---|
| Requirement ID | REQ-FEE-003 |
| Module | FEE |
| Priority | High |
| Test Type | API / Date Boundary |
| Preconditions | One semester contains test date and student has invoice in it. |
| Test Data | Omit `semester_id`; test on start date, middle date, and end date if clock/data control is available. |
| Test Steps | 1. GET `/studentfee/my-invoice` without query.<br>2. Verify selected semester against inclusive start/end rule. |
| Expected Result | HTTP 200 for the date-covering semester; start and end dates are included due to `lte/gte` query. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-FEE-005 — Missing current semester or invoice

| Field | Value |
|---|---|
| Requirement ID | REQ-FEE-005 |
| Module | FEE |
| Priority | Medium |
| Test Type | API / Negative / Resource Not Found |
| Preconditions | Controlled variants: no date-covering semester; no invoice for valid student/semester. |
| Test Data | Valid token and identifiers |
| Test Steps | 1. Request own invoice without semester in no-current dataset.<br>2. Request absent invoice with explicit semester. |
| Expected Result | No current semester: HTTP 404 `No current semester found`. Missing invoice: HTTP 404 `Invoice not found`. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-FEE-006 — Retrieve another student's current invoice

| Field | Value |
|---|---|
| Requirement ID | REQ-FEE-006 |
| Module | FEE |
| Priority | High |
| Test Type | API / Functional |
| Preconditions | Target user and current invoice exist. |
| Test Data | Target user UUID (despite route variable being named username) |
| Test Steps | 1. GET `/studentfee/invoice/{target_uuid}` with a valid token.<br>2. Compare owner/semester/items/total to target records. |
| Expected Result | HTTP 200; invoice belongs to target UUID and current date-covering semester; total is correct. |
| Actual Result | All documented test steps and data variants were executed. The API returned HTTP 200; the invoice belonged to the target student and current date-covering semester, and the items and total matched the expected records. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. Evidence: [TC-FEE-006](../images/TC-FEE-006.png). |

### TC-FEE-007 — Another-student invoice with invalid/not-found ID

| Field | Value |
|---|---|
| Requirement ID | REQ-FEE-005, REQ-FEE-006 |
| Module | FEE |
| Priority | Medium |
| Test Type | API / Negative / Invalid Resource ID |
| Preconditions | Current semester exists. |
| Test Data | Unknown UUID; username string rather than UUID; empty path is not route-matchable |
| Test Steps | 1. Call endpoint for each path value.<br>2. Record status/body/log. |
| Expected Result | Unknown identifier returns HTTP 404 `Invoice not found`; malformed database identifier should return a controlled 4xx. Exact malformed-ID behavior is TBD due to missing DDL. |
| Actual Result | The unknown UUID, username string used instead of a UUID, and empty-path variants all returned HTTP 500 instead of the expected controlled 4xx/404 responses. |
| Status | Failed |
| Defect ID | DEF-FEE-001 |
| Notes | Failed because all three invalid/not-found path variants returned HTTP 500. See `DEF-FEE-001`. |

### TC-FEE-008 — Mark invoice paid

| Field | Value |
|---|---|
| Requirement ID | REQ-FEE-007 |
| Module | FEE |
| Priority | High |
| Test Type | API / State Transition / Database Validation |
| Preconditions | Authenticated; isolated unpaid invoice exists. |
| Test Data | Valid invoice UUID |
| Test Steps | 1. Record invoice and items.<br>2. POST `/studentfee/pay/{invoice_id}`.<br>3. Read invoice/items again.<br>4. Repeat with unknown ID. |
| Expected Result | Existing: HTTP 200, status becomes `paid`, items remain, response conforms to schema. Unknown: HTTP 404 `Invoice not found or not updated`. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

## PAY — Intent, OTP, and confirmation (15 cases)

### TC-PAY-001 — Create self-payment intent

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-001, REQ-PAY-002, REQ-PAY-005 |
| Module | PAY |
| Priority | High |
| Test Type | API / Functional / Database Validation |
| Preconditions | Authenticated payer has unpaid positive invoice and profile email. |
| Test Data | Body `{ "student_id": null, "semester_id": "<semester>" }` |
| Test Steps | 1. POST `/payment/intents`.<br>2. Inspect response.<br>3. Verify new intent row against payer/invoice. |
| Expected Result | HTTP 200; one `pending` intent with payer/beneficiary equal JWT subject, correct email/invoice/total, and no client-supplied payer override. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-PAY-002 — Create intent for another student

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-003, REQ-PAY-005 |
| Module | PAY |
| Priority | High |
| Test Type | API / Functional / Database Validation |
| Preconditions | Payer authenticated; target student has current unpaid invoice. |
| Test Data | `student_id=<target_uuid>` |
| Test Steps | 1. POST `/payment/intents` with target UUID.<br>2. Compare intent with payer, target, and target's current invoice. |
| Expected Result | HTTP 200; payer is JWT subject; beneficiary/invoice belong to target; amount equals target invoice total; status `pending`. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-PAY-003 — Reject paid or non-positive invoice

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-004 |
| Module | PAY |
| Priority | High |
| Test Type | API / Negative / Boundary |
| Preconditions | Variant A paid invoice; Variant B unpaid invoice with total zero/negative in disposable data. |
| Test Data | Corresponding self/target IDs |
| Test Steps | 1. Attempt intent creation for each variant.<br>2. Verify response and absence of new intent. |
| Expected Result | HTTP 400; paid detail indicates invoice cannot be paid again; non-positive detail indicates invalid total; no intent created. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-PAY-004 — Intent input normalization and not-found data

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-002, REQ-PAY-003 |
| Module | PAY |
| Priority | Medium |
| Test Type | API / Negative / Validation |
| Preconditions | Authenticated payer. |
| Test Data | Empty string; literal `string`; whitespace; unknown student/semester; incorrect JSON types |
| Test Steps | 1. Submit each body.<br>2. Record whether value normalizes to self flow or fails.<br>3. Verify no unintended target intent. |
| Expected Result | Empty/whitespace/literal `string` normalize to absent and use self flow; unknown resource returns upstream 404/controlled 4xx; wrong types return 422. |
| Actual Result | Empty string, whitespace, and literal `string` values normalized to the authenticated payer and returned that user's self-payment flow as expected. Incorrect JSON types returned HTTP 422 as expected. Unknown student and unknown semester values returned HTTP 500 instead of controlled 404/4xx responses. |
| Status | Failed |
| Defect ID | DEF-PAY-001 |
| Notes | Normalization and request-schema validation variants passed; unknown student and semester handling failed with HTTP 500. See `DEF-PAY-001`. |

### TC-PAY-005 — Duplicate open intent submission

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-005 |
| Module | PAY |
| Priority | High |
| Test Type | API / Duplicate Submission / Database Validation |
| Preconditions | One open intent exists for invoice; database unique rule expected by code is present. |
| Test Data | Same payer/invoice request twice, including rapid double-click |
| Test Steps | 1. Create first intent.<br>2. Immediately send identical request twice.<br>3. Count open intents. |
| Expected Result | Only one open intent exists; duplicates return controlled HTTP 400 with processing/wait detail; no duplicate financial action. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-PAY-006 — Send first OTP

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-006, REQ-PAY-012 |
| Module | PAY |
| Priority | High |
| Test Type | API / Functional / Email / Database Validation |
| Preconditions | Payer owns a pending intent; SMTP is configured and the recipient email is accessible. |
| Test Data | Valid intent ID |
| Test Steps | 1. POST `/payment/intents/{id}/send-otp`.<br>2. Verify HTTP response.<br>3. Check that the OTP email is received.<br>4. Inspect intent fields and expiry. |
| Expected Result | HTTP 200 with matching ID and otp_sent=true; a six-digit zero-padded OTP is delivered to the registered email address; intent status becomes otp_sent; attempt count increments; expiry is approximately 180 seconds after sending. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. Live OTP values are excluded from committed evidence. |

### TC-PAY-007 — Resend before and after expiry

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-006 |
| Module | PAY |
| Priority | High |
| Test Type | API / Retry / Time Boundary |
| Preconditions | Intent has an OTP with known expiry. |
| Test Data | Same intent ID; calls immediately before and after expiry |
| Test Steps | 1. Call send-otp while code is valid.<br>2. Check email count/code/attempt.<br>3. Wait until controlled expiry and call again.<br>4. Check new fields. |
| Expected Result | Intended active-code message says pre-expiry resend should be rejected without change; post-expiry resend should issue a new code/expiry and increment attempts. Compare pre-expiry observation with PI-PAY-002. |
| Actual Result | A resend request made before OTP expiry returned HTTP 200, generated and emailed a new OTP, and incremented `otp_attempts` instead of rejecting the request without change. Resending after expiry worked as expected. |
| Status | Failed |
| Defect ID | DEF-PAY-002 |
| Notes | The post-expiry resend variant passed. The pre-expiry guard failed and reproduced `PI-PAY-002`; see `DEF-PAY-002`. |

### TC-PAY-008 — Send OTP for invalid resource or state

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-006, REQ-PAY-008 |
| Module | PAY |
| Priority | Medium |
| Test Type | API / Negative / Invalid Resource ID |
| Preconditions | Unknown ID; confirmed/failed intents available. |
| Test Data | Unknown UUID, malformed ID, confirmed ID, failed ID |
| Test Steps | 1. POST send-otp for each.<br>2. Inspect state/email and response. |
| Expected Result | Unknown/malformed resources produce controlled 4xx and no mail. Disallowed states must not receive/change OTP. Exact current-state enforcement on send is a verification target because active service lacks an explicit status check. |
| Actual Result | Unknown and malformed intent IDs produced controlled 4xx responses without sending email. For both `confirmed` and `failed` intents, the API still returned success, generated a new OTP, updated OTP data, and sent a new email. |
| Status | Blocked |
| Defect ID | N/A |
| Notes | Blocked pending confirmation of allowed OTP operations for terminal intent states; no defect ID is assigned. |

### TC-PAY-009 — Confirm request-body validation

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-007 |
| Module | PAY |
| Priority | High |
| Test Type | API / Boundary / Incorrect Data Type |
| Preconditions | Valid otp-sent intent. |
| Test Data | 5 digits, 7 digits, letters, mixed, empty, null, missing, numeric JSON value, exactly 6 digits |
| Test Steps | 1. POST confirm for invalid body variants before using valid code.<br>2. Verify status and no balance/state mutation. |
| Expected Result | Every non-string/non-six-digit-numeric input returns HTTP 422; exactly six digits passes schema validation and proceeds to service validation. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-PAY-010 — Confirm with correct OTP

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-009 |
| Module | PAY |
| Priority | Critical |
| Test Type | API / End-to-End / Database Validation |
| Preconditions | Valid owned otp-sent intent; payer balance ≥ amount; dependencies available. |
| Test Data | Correct controlled OTP |
| Test Steps | 1. Snapshot payer, invoice, intent, payment rows.<br>2. POST confirm within expiry.<br>3. Inspect response.<br>4. Re-read every record and receipt destinations. |
| Expected Result | HTTP 200; balance decreases exactly once; invoice `paid`; intent `confirmed` with OTP fields cleared; one payment has correct amount/before/after; response matches `ConfirmResp`; receipt attempted for correct recipient(s). |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-PAY-011 — Confirm incorrect or expired OTP

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-008 |
| Module | PAY |
| Priority | Critical |
| Test Type | API / Negative / Time Boundary / Database Validation |
| Preconditions | Separate otp-sent intents for wrong and expired variants. |
| Test Data | Wrong six-digit code; correct code after expiry |
| Test Steps | 1. Snapshot data.<br>2. Confirm wrong code.<br>3. Confirm expired code on separate intent.<br>4. Verify all financial records. |
| Expected Result | HTTP 422 with OTP-specific detail; wrong-code intent is not debited/confirmed; expired intent becomes `expired`; no invoice/payment/balance change. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-PAY-012 — Confirm invalid intent state and duplicate confirmation

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-008, REQ-PAY-010 |
| Module | PAY |
| Priority | Critical |
| Test Type | API / State Transition / Duplicate Submission |
| Preconditions | Confirmed, processing, failed/cancelled, and pending-without-OTP intents. |
| Test Data | Each intent ID and appropriate six-digit input |
| Test Steps | 1. Submit confirm for each state.<br>2. Submit a second confirm after one successful TC-PAY-010.<br>3. Compare balances/payments. |
| Expected Result | HTTP 422 with state-specific detail; no second debit/payment; pending without OTP returns `Chưa phát OTP`; financial state remains unchanged. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-PAY-013 — Concurrent confirmation

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-010 |
| Module | PAY |
| Priority | Critical |
| Test Type | API / Concurrency / Database Validation |
| Preconditions | One valid otp-sent intent; synchronized client. |
| Test Data | Same correct OTP in two simultaneous confirm requests |
| Test Steps | 1. Snapshot all records.<br>2. Fire two synchronized confirms.<br>3. Record both responses.<br>4. Verify final data. |
| Expected Result | At most one request performs processing/debit; one confirmed intent/payment; balance reduced once; competing request receives controlled 422/state/race detail. |
| Actual Result | Two simultaneous confirmation requests were executed for the same intent and OTP. Only one request completed with HTTP 200 and performed the debit/payment; the competing request was rejected in a controlled manner. The balance was reduced once and only one confirmed payment remained. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Execution completed and the observed result is recorded above. |

### TC-PAY-014 — Cancel intent and repeat cancel

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-011 |
| Module | PAY |
| Priority | High |
| Test Type | API / State Transition / Duplicate Submission |
| Preconditions | Owned pending/otp-sent intent. |
| Test Data | Valid ID; unknown ID; repeat same ID |
| Test Steps | 1. POST cancel.<br>2. Verify response/row.<br>3. Repeat cancel and try confirm.<br>4. Cancel unknown ID. |
| Expected Result | First returns HTTP 200 with `failed`; later confirm is rejected and no debit occurs. Repeat behavior and allowed source states require confirmation; unknown ID returns controlled 400. |
| Actual Result | The first cancel request returned HTTP 200 and changed the intent to `failed`. Repeating cancel also returned HTTP 200 without changing the final state. A later confirm was rejected with no debit or payment, and an unknown intent ID returned HTTP 400. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Execution completed and the observed result is recorded above. |

### TC-PAY-015 — Cross-user forbidden intent actions

| Field | Value |
|---|---|
| Requirement ID | REQ-PAY-001 |
| Module | PAY |
| Priority | Critical |
| Test Type | API / Forbidden Access / Database Validation |
| Preconditions | User A owns an intent; User B is authenticated; controlled OTP if confirm is attempted. |
| Test Data | A's intent ID with B's bearer token |
| Test Steps | 1. Snapshot A's intent/balance.<br>2. As B, call send-otp, cancel, and confirm.<br>3. Verify response/email/state/balance. |
| Expected Result | A caller must not mutate another payer's intent; expected authorization response is 403 and no change. Exact ownership policy is **TBD – Requires confirmation**; compare results with PI-PAY-001. |
| Actual Result | Authenticated User B successfully sent OTP, cancelled, and confirmed User A's payment intent. The API did not return HTTP 403; the intent state changed and the requested operations were applied. |
| Status | Blocked |
| Defect ID | N/A |
| Notes | Blocked because the intent ownership policy is not formally confirmed. The observation reproduced `PI-PAY-001`; no defect ID is assigned. |

### TC-HIST-001 — Retrieve completed self-related history

| Field | Value |
|---|---|
| Requirement ID | REQ-HIST-001, REQ-HIST-003, REQ-HIST-004 |
| Module | HIST |
| Priority | High |
| Test Type | API / Functional / Database Validation |
| Preconditions | Authenticated user has completed payments as payer and/or beneficiary in selected semester. |
| Test Data | User UUID and semester ID |
| Test Steps | 1. GET `/payment/payments/history/{user}/{semester}`.<br>2. Compare rows to payment/intent/user data.<br>3. Check order. |
| Expected Result | HTTP 200 array; only relevant intended rows; amount/IDs/usernames correct; records ordered by `paid_at` descending. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-HIST-002 — Empty history

| Field | Value |
|---|---|
| Requirement ID | REQ-HIST-002 |
| Module | HIST |
| Priority | Medium |
| Test Type | API / Empty Data / Resource Not Found |
| Preconditions | Variants: no invoice; invoice but no intent; intent but no payment. |
| Test Data | Valid identifiers for each isolated variant |
| Test Steps | 1. Request each variant.<br>2. Inspect response and logs. |
| Expected Result | HTTP 200 with `[]` for all three empty-data variants. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-HIST-003 — Invalid history parameters and missing auth

| Field | Value |
|---|---|
| Requirement ID | REQ-HIST-001 |
| Module | HIST |
| Priority | High |
| Test Type | API / Negative / Unauthorized / Invalid Resource ID |
| Preconditions | Gateway/payment service available. |
| Test Data | Missing token; malformed/unknown student ID; malformed/unknown semester ID; missing path segment |
| Test Steps | 1. Send each request variant.<br>2. Verify status/body and absence of data leakage. |
| Expected Result | Missing token returns 401; missing segment returns 404 route-not-found; unknown valid identifiers return `[]`; malformed database values return controlled 4xx. |
| Actual Result | Requests with missing authentication and malformed/invalid parameters returned controlled 4xx responses. An unknown valid semester ID returned HTTP 200 with an empty array and no data leakage. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Execution completed and the observed result is recorded above. |

### TC-HIST-004 — Semester isolation

| Field | Value |
|---|---|
| Requirement ID | REQ-HIST-003 |
| Module | HIST |
| Priority | High |
| Test Type | API / Data Filtering / Database Validation |
| Preconditions | Same user has completed payments linked to invoices in at least two semesters. |
| Test Data | Semester A and B IDs |
| Test Steps | 1. Request history for A.<br>2. Map each payment → intent → invoice → semester.<br>3. Repeat for B.<br>4. Compare sets. |
| Expected Result | Each response contains only payments associated with the requested semester. Compare any cross-semester rows with PI-HIST-002. |
| Actual Result | Not executed because no student had completed payment data in at least two semesters. |
| Status | Not Run |
| Defect ID | N/A |
| Notes | Not Run because the required cross-semester payment-history dataset was unavailable. |

### TC-HIST-005 — Cross-user history authorization

| Field | Value |
|---|---|
| Requirement ID | REQ-HIST-001 |
| Module | HIST |
| Priority | High |
| Test Type | API / Forbidden Access |
| Preconditions | User A authenticated; User B has history. |
| Test Data | B's UUID/semester with A's token |
| Test Steps | 1. Request B's history as A.<br>2. Inspect response fields.<br>3. Confirm intended pay-on-behalf visibility with owner. |
| Expected Result | Sensitive history must follow an explicit authorization policy. Proposed self-only behavior is HTTP 403 with no data; final expected policy is **TBD – Requires confirmation**. Compare PI-HIST-001. |
| Actual Result | Authenticated User A retrieved User B's payment history successfully. The response contained User B's payment records and no authorization rejection was returned. |
| Status | Blocked |
| Defect ID | N/A |
| Notes | Blocked because the cross-user history visibility policy is not formally confirmed. The observation reproduced `PI-HIST-001`; no defect ID is assigned. |

### TC-UI-001 — Login form validation and password visibility

| Field | Value |
|---|---|
| Requirement ID | REQ-UI-001 |
| Module | UI |
| Priority | High |
| Test Type | UI / Validation |
| Preconditions | Login page open. |
| Test Data | Empty username/password combinations; sample password |
| Test Steps | 1. Submit each empty combination.<br>2. Verify alert and network.<br>3. Enter password and toggle eye button twice. |
| Expected Result | Empty submission shows `Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu` and sends no login request; eye control toggles password/text display without changing value. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-UI-002 — Successful and failed login navigation

| Field | Value |
|---|---|
| Requirement ID | REQ-UI-002 |
| Module | UI |
| Priority | High |
| Test Type | UI / Functional / Negative |
| Preconditions | Valid and invalid synthetic credentials. |
| Test Data | One valid pair; one invalid pair |
| Test Steps | 1. Submit invalid pair and close alert.<br>2. Submit valid pair.<br>3. Inspect route/localStorage and Home request. |
| Expected Result | Invalid displays backend detail and stays on login with no token. Valid stores token, navigates `/home`, and loads current profile. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-UI-003 — Home data display and formatting

| Field | Value |
|---|---|
| Requirement ID | REQ-UI-003, REQ-UI-004, REQ-UI-009 |
| Module | UI |
| Priority | High |
| Test Type | UI / Functional / Data Presentation |
| Preconditions | Logged-in user has profile, semester, multi-item invoice, and history. |
| Test Data | Known timestamps/amounts including thousands and decimals |
| Test Steps | 1. Open Home.<br>2. Compare profile and selected invoice to APIs.<br>3. Change semester.<br>4. Verify item/history tables, empty states, currency, and dates. |
| Expected Result | Display matches API; date uses Asia/Ho_Chi_Minh Vietnamese format; amounts use Vietnamese separators; selected semester refreshes own invoice/history; missing rows show defined empty text. |
| Actual Result | The current semester initially displayed the correct invoice. After another semester was selected, the course count changed correctly but the invoice remained from the previous semester instead of refreshing to the selected semester. |
| Status | Failed |
| Defect ID | DEF-UI-003 |
| Notes | Failed because the invoice display was not synchronized with the selected semester. See `DEF-UI-003`. |

### TC-UI-004 — Terms gate and self/other lookup flows

| Field | Value |
|---|---|
| Requirement ID | REQ-UI-005 |
| Module | UI |
| Priority | High |
| Test Type | UI / Functional / Decision Table |
| Preconditions | Logged in; self and target unpaid invoices exist. |
| Test Data | Valid target MSSV/username; unknown username |
| Test Steps | 1. Verify self Pay disabled before accepting terms and enabled after.<br>2. Open/read/close terms.<br>3. Switch to other tab and search unknown then valid target.<br>4. Verify Pay gating and displayed target data. |
| Expected Result | Pay remains disabled until checkbox selected; unknown search shows `Không tìm thấy sinh viên.`; valid search displays target/current invoice; terms modal works in both flows. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-UI-005 — Insufficient balance and top-up validation

| Field | Value |
|---|---|
| Requirement ID | REQ-UI-006 |
| Module | UI |
| Priority | High |
| Test Type | UI / Boundary / Validation / Database Validation |
| Preconditions | Payer balance below self/other invoice total; terms accepted. |
| Test Data | Empty, non-numeric, zero, negative, amount leaving total short by `0.01`, exact required amount, valid larger amount |
| Test Steps | 1. Click Pay and open top-up.<br>2. Try each invalid/insufficient value.<br>3. Submit exact valid amount.<br>4. Verify UI and database balance. |
| Expected Result | Insufficient modal appears; invalid/non-positive message shown; still-insufficient sum is rejected; valid deposit updates database and displayed balance and shows success. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-UI-006 — OTP input, timer, resend, and cancel

| Field | Value |
|---|---|
| Requirement ID | REQ-UI-007, REQ-UI-008 |
| Module | UI |
| Priority | High |
| Test Type | UI / Boundary / State Transition |
| Preconditions | Payment flow opened OTP modal. |
| Test Data | Letters/mixed input; 5/6/7 digits; controlled timer; valid intent |
| Test Steps | 1. Paste/type each value and observe normalized field/button.<br>2. Observe countdown to zero.<br>3. Try confirm at zero.<br>4. Resend and inspect reset.<br>5. Cancel and inspect state/message. |
| Expected Result | Non-digits removed; max six; confirm disabled until six; timer begins 3:00 and reaches 0:00; expiry enables resend; resend resets to 3:00/clears input; cancel closes modal and marks intent failed through API. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

### TC-UI-007 — End-to-end payment success and recovery on refresh

| Field | Value |
|---|---|
| Requirement ID | REQ-UI-004, REQ-UI-005, REQ-UI-007 |
| Module | UI |
| Priority | Critical |
| Test Type | UI / End-to-End / Basic Regression |
| Preconditions | Sufficient balance, unpaid invoice, controlled OTP mailbox. |
| Test Data | Self flow then separate other-student flow |
| Test Steps | 1. Accept terms and start self-payment.<br>2. Enter correct OTP.<br>3. Verify success, refresh, balance/invoice/history.<br>4. Repeat for another student.<br>5. During a separate open intent, refresh before confirm and inspect recovery/network. |
| Expected Result | Successful flows show success and persisted correct state/history; other flow identifies payer/beneficiary correctly. Refresh should not duplicate payment. Active-intent restoration is TBD; record missing `/payment/intents/current` behavior against PI-UI-001. |
| Actual Result | All documented test steps and data variants were executed. The observed responses, validation behavior, returned data, and resulting application/database state matched the Expected Result. |
| Status | Passed |
| Defect ID | N/A |
| Notes | Passed within the documented test scope; no defect was observed. |

## Requirement traceability summary

| Requirement group | Test case range |
|---|---|
| REQ-AUTH | TC-AUTH-001 to TC-AUTH-010 |
| REQ-USER | TC-USER-001 to TC-USER-008 |
| REQ-FEE | TC-FEE-001 to TC-FEE-008 |
| REQ-PAY | TC-PAY-001 to TC-PAY-015 |
| REQ-HIST | TC-HIST-001 to TC-HIST-005 |
| REQ-UI | TC-UI-001 to TC-UI-007 |

**Total designed test cases: 53**  
**Executed: 51 · Passed: 43 · Failed: 5 · Blocked: 3 · Not Run: 2**
