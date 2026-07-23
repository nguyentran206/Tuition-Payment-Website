# Defect Report Template

> Use this template only after an issue has been reproduced through test execution. Code-review hypotheses belong in `potential-issues.md` until confirmed. Remove or redact passwords, JWTs, OTPs, service keys, personal data, and private URLs from evidence.

## Defect record

| Field | Value |
|---|---|
| Defect ID | DEF-[MODULE]-[NNN] |
| Title | [Concise observable problem] |
| Description | [What is wrong, where, and under what condition] |
| Environment | [Commit SHA, date, OS, browser/client version, service URLs, database dataset; no secrets] |
| Module | [AUTH / USER / FEE / PAY / HIST / UI] |
| Preconditions | [Required user, data, session, and system state] |
| Steps to Reproduce | 1. [Step]\n2. [Step]\n3. [Step] |
| Test Data | [Synthetic identifiers/input; redact sensitive data] |
| Expected Result | [Requirement-based observable result] |
| Actual Result | [Observed result, exact sanitized error/status/body] |
| Severity | [Critical / High / Medium / Low] |
| Priority | [P0 / P1 / P2 / P3] |
| Reproducibility | [Always / Intermittent / Once / X of Y attempts] |
| Evidence | [Relative screenshot/log/request-response/database evidence links] |
| Related Test Case | [TC-...] |
| Status | [Open / In Progress / Fixed / Ready for Retest / Reopened / Closed / Rejected / Duplicate] |
| Assigned To | [Name or TBD] |
| Reported Date | [YYYY-MM-DD] |
| Retest Result | [Not Retested / Pass / Fail plus build and evidence] |
| Notes | [Impact, workarounds, links, related issues] |

## Severity and priority

**Severity** describes technical/user impact:

- **Critical**: data loss/corruption, duplicate financial effect, broad outage, or no safe workaround for a core flow.
- **High**: core login/payment/invoice function fails or authorization exposes/modifies another user's sensitive data.
- **Medium**: meaningful behavior is wrong but a workaround exists or the core transaction remains safe.
- **Low**: cosmetic, wording, minor usability, or low-impact inconsistency.

**Priority** describes how soon the issue should be addressed:

- **P0**: immediate action; blocks safe testing/release.
- **P1**: fix in the current iteration/release.
- **P2**: schedule after higher-risk work.
- **P3**: backlog or opportunistic improvement.

Severity and priority are independent. For example, a highly visible wording issue can be low severity but higher priority, while a rare integrity issue can be critical severity even if reproduction work affects scheduling.

## Status definitions

| Status | Meaning |
|---|---|
| Open | Reproduced, documented, and awaiting triage/work. |
| In Progress | Investigation or implementation is active. |
| Fixed | Developer reports a fix, but tester has not yet retested it. |
| Ready for Retest | Fix is available in an identified test build/environment. |
| Reopened | Retest failed or the same issue recurred. |
| Closed | Retest passed and relevant regression evidence is recorded. |
| Rejected | Triage determined the report is not a defect; include rationale. |
| Duplicate | Same root issue is already tracked; link the primary defect. |

## Evidence checklist

- Include the exact commit/build and timestamp.
- Include request method/path, sanitized headers/body, response status/body for API issues.
- Include before/after records for data-integrity issues.
- Capture one full screen plus a focused image for UI issues when useful.
- Name evidence with the defect ID and keep links relative to the repository.
- Never commit `.env`, access tokens, live OTPs, passwords, private keys, or real student data.
