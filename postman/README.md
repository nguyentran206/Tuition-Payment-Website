# Postman API Testing Assets

## Status

The collection and environment are prepared from active FastAPI routes and were used as the basis for local API execution. Passing/failing claims remain defined by the manual test cases; sanitized Postman screenshots are indexed in [`docs/images/README.md`](../docs/images/README.md). Review variables and synthetic data before each new run.

Files:

- `tuition-payment-api.postman_collection.json`
- `local.postman_environment.json`

## Safe setup

1. Start the five backend processes listed in the root README.
2. Import both JSON files into Postman.
3. Select **Tuition Payment - Local (Template)**.
4. Fill only local, non-secret identifiers. Leave `access_token`, password, OTP, and service credentials out of committed files.
5. Run **Auth → Login** manually; its test script saves the returned JWT only to the selected local environment.
6. Populate IDs from your synthetic Supabase dataset or captured responses.
7. Execute state-changing requests only against a disposable non-production dataset.
8. Export evidence with tokens, OTPs, emails, and student information redacted.

## Variables

| Variable | Purpose | Default/template |
|---|---|---|
| `base_url` | Gateway | `http://localhost:8000` |
| `auth_service_url` | Direct Auth service; required for signup | `http://localhost:8001` |
| `payment_service_url` | Direct Payment service health endpoint | `http://localhost:8004` |
| `access_token` | Runtime JWT set after login | Empty |
| `username`, `password` | Synthetic login credentials | Empty |
| `signup_*` | Unique synthetic signup data | Empty |
| `user_id`, `other_username`, `other_user_id` | Synthetic User identifiers | Empty |
| `semester_id`, `invoice_id` | Synthetic Student Fee identifiers | Empty |
| `intent_id`, `otp` | Runtime Payment values | Empty |
| `amount` | Positive decimal for deposit/debit | `1000.00` |

## Endpoint inventory

All content requests use `Content-Type: application/json`. Protected requests use `Authorization: Bearer {{access_token}}`. Generated validation responses are usually 422. Gateway/upstream failures may surface as 4xx/5xx depending on the downstream status.

### Gateway and Auth

| Method and URL | Auth | Parameters/body | Success | Expected error examples |
|---|---|---|---:|---|
| `GET {{base_url}}/` | No | None | 200 | Service unavailable/network error |
| `POST {{base_url}}/auth/login` | No | `{username,password}` | 200 | 401 invalid credentials; 422 invalid body |
| `GET {{base_url}}/auth/verify` | Bearer | None | 200 | 401 invalid/expired token; missing-header status should be recorded |
| `POST {{auth_service_url}}/auth/signup` | No | `{username,email,name,password}` | 200 | 400 duplicate/upstream failure; 422 invalid email/body |

`POST /auth/signup` is intentionally direct-service in the collection because the gateway Auth catch-all does not allow POST. Desired gateway exposure is **TBD – Requires confirmation**.

### User

| Method and URL | Auth | Parameters/body | Success | Expected error examples |
|---|---|---|---:|---|
| `POST {{base_url}}/user/create` | No | `{username,email,name}` | 200 | 400 missing empty fields/DB error; 422 invalid body/email |
| `GET {{base_url}}/user/me` | Bearer | None | 200 | 401 missing/invalid token; 404 no profile |
| `GET {{base_url}}/user/by-id/{{user_id}}` | Bearer | `user_id` path | 200 | 401; 404 unknown user; DB-dependent malformed-ID error |
| `GET {{base_url}}/user/by-username/{{other_username}}` | Bearer | username path | 200 | Intended 404; current behavior requires verification (PI-USER-001) |
| `POST {{base_url}}/user/{{user_id}}/debit` | Bearer | `{amount}` | 200 | 401; 404; 409 insufficient/concurrent change; 422 invalid amount |
| `POST {{base_url}}/user/{{user_id}}/deposit` | Bearer | `{amount}` | 200 | 401; 404; 409 concurrent change; 422 invalid amount |

### Student Fee

| Method and URL | Auth | Parameters/body | Success | Expected error examples |
|---|---|---|---:|---|
| `GET {{base_url}}/studentfee/semesters` | Bearer | None | 200 | 401; 404 empty list |
| `GET {{base_url}}/studentfee/my-invoice?semester_id={{semester_id}}` | Bearer | Optional query | 200 | 401; 404 no current semester/invoice |
| `GET {{base_url}}/studentfee/invoice/{{other_user_id}}` | Not enforced by service | Target UUID path | 200 | 404 invoice/current semester missing; access policy TBD |
| `POST {{base_url}}/studentfee/pay/{{invoice_id}}` | Bearer | Invoice ID path | 200 | 401; 404 not found/not updated |

Despite the route variable name `username`, active service logic treats the other-invoice path value as `student_id`/UUID.

### Payment

| Method and URL | Auth | Parameters/body | Success | Expected error examples |
|---|---|---|---:|---|
| `POST {{base_url}}/payment/intents` | Bearer | `{student_id?,semester_id?}` | 200 | 400 paid/invalid/duplicate invoice; 401; upstream 4xx/502; 422 body |
| `POST {{base_url}}/payment/intents/{{intent_id}}/send-otp` | Bearer | Intent ID path | 200 | 400 invalid intent/resend/data error; 401 |
| `POST {{base_url}}/payment/intents/{{intent_id}}/confirm` | Bearer | `{otp}` | 200 | 401; 422 schema/OTP/state error; upstream status; 500 unexpected/partial failure |
| `POST {{base_url}}/payment/intents/{{intent_id}}/cancel` | Bearer | Intent ID path | 200 | 400 invalid/update error; 401 |
| `GET {{base_url}}/payment/payments/history/{{user_id}}/{{semester_id}}` | Bearer | Two path parameters | 200 | 400 repository/upstream error; 401; route 404 for missing segment |
| `GET {{payment_service_url}}/healthz` | No | None | 200 | Service unavailable |

## Requests not added as working endpoints

- `GET /payment/intents/current`: referenced by the frontend but absent from `backend/payment/router.py`.
- `GET /payments/history?payer_id=...`: an unused frontend helper references this path, but no gateway/payment route implements it.
- Commented-out backend routes are not included.

## Suggested execution order

1. Gateway health and Payment direct health.
2. Login, then Verify Token and Get Me.
3. List Semesters and Get My Invoice.
4. Create Intent → Send OTP → Confirm Intent, or Cancel Intent.
5. Get Payment History and verify database records.
6. Run negative duplicates/invalid IDs/invalid OTP in isolated data.

Do not run the whole collection sequentially without preparing unique/resettable data: debit, deposit, pay, signup, confirm, and cancel mutate persistent state.
