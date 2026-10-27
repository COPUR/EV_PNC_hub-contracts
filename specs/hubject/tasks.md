# Tasks: Hubject connector

Format: `T-ID | title | requirements | depends on | environment | exit check`

- T-HUBJECT-01 | Pin contracts and add a drift check in CI | SEC-003 | none | none | `fetch_public_contracts.py` runs in CI and the diff is reviewed
- T-HUBJECT-02 | Generate OICP server stubs and client from the pinned EMP contract | AUTH-001, CMD-001, CDR-001 | T-01 | none | project compiles; stubs match pinned paths
- T-HUBJECT-03 | Hub mock from the pinned contract | AUTH-001, CMD-001, CDR-001, LOC-001 | T-01 | mock | mock serves every EMP operation
- T-HUBJECT-04 | Certificate-bound identity, environment config and version declaration | SEC-001..004 | T-02 | mock | `oicp-security.feature` passes
- T-HUBJECT-05 | Authorize endpoint with policy hook | AUTH-001..003, AUTH-006, PNC-007 | T-02, policy-engine API | mock | `oicp-authorize.feature` passes
- T-HUBJECT-06 | Remote start client | CMD-001 | T-02 | mock | remote start scenarios pass
- T-HUBJECT-07 | CDR receiver, idempotency, pricing hook | CDR-001, CDR-002 | T-02, payments API | mock | CDR scenarios pass
- T-HUBJECT-08 | Generate EVSE data and status mapping from the pinned schema | LOC-001 | T-02, analysis WP4 | mock | `oicp-evse-data.feature` passes
- T-HUBJECT-09 | OPCP MO clients (PCP, RCP, CCP, CPS) with OAuth2 | PNC-001, PNC-002, PNC-004, PNC-005 | T-01 | mock | `opcp-contract-provisioning.feature` passes
- T-HUBJECT-10 | Chain validation against RCP roots | PNC-001 | T-09 | mock | invalid-chain scenario passes
- T-HUBJECT-11 | Overlay profile and pins (webhook payload, NGP) | CMD-002, LOC-003, LOC-004, OPS-002 | T-01 | none | profile parses; fetch script pins 2 files
- T-HUBJECT-12 | Remote stop client with ProviderID path | CMD-002, CMD-003 | T-02, T-11 | mock | remote-stop scenario passes
- T-HUBJECT-13 | Charging notifications receiver | CDR-003 | T-02 | mock | notifications scenarios pass
- T-HUBJECT-14 | Authorize time budget and 021 fallback | AUTH-004 | T-05 | mock | timeout scenario passes
- T-HUBJECT-15 | CDR reconciliation job | CDR-004 | T-07 | mock | reconciliation scenario passes
- T-HUBJECT-16 | Paginated EVSE pull, delta, status by operator | LOC-003, LOC-004 | T-08, T-11 | mock | pagination scenarios pass
- T-HUBJECT-17 | Throttler and 429 backoff | OPS-002 | T-02 | mock | rate-limit scenario passes
- T-HUBJECT-18 | OPCP webhook receiver (HMAC, idempotency, PCID invalidation) | PNC-006, PNC-008 | T-09 | mock | webhook scenarios pass
- T-HUBJECT-19 | NGP contracts client and tariff mapping | TARIFF-001 | T-11 | mock | NGP scenario passes
- T-HUBJECT-20 | OPCP environment config and EMAID normalisation | PNC-009, PNC-010 | T-09 | mock | config scenarios pass
- T-HUBJECT-21 | Onboarding runbook (CSRs, IPs, portal flags, Provider ID, AUP, ops rules) | SEC-005, SEC-006, REG-001, REG-002, OPS-003 | none | none | runbook reviewed by ops
- T-HUBJECT-22 | Procure RFID test cards and submit UIDs | CERT-002 | contract signed | none | UIDs acknowledged by Hubject
- T-HUBJECT-23 | QA E2E protocol and live test, then PROD repeat | CERT-001 | T-04..T-07, T-12, T-21, T-22 | hub sandbox | protocol approved; live test passed; **blocked by the Hubject contract**
- T-HUBJECT-24 | StatusCode catalogue (32 codes + unknown-code tolerance) and response builder | ERR-001, ERR-002 | T-02 | mock | `oicp-errors.feature` status-code scenarios pass
- T-HUBJECT-25 | Authorize decision → StatusCode mapping table as configuration (pending Q-ERR-1) | ERR-001 | T-24, T-05 | mock | unknown-UID and policy scenarios pass; blocked on Q-ERR-1 for final codes
- T-HUBJECT-26 | Remote start and stop failure handling, message keys, 65 s timeouts, unknown-state resolver | ERR-004, ERR-005 | T-06, T-12 | mock | remote failure and timeout scenarios pass
- T-HUBJECT-27 | Certificate expiry monitor and 017 handling | ERR-003 | T-04 | mock | cert scenarios pass
- T-HUBJECT-28 | CDR answer-first pipeline, parking queue, outage replay | ERR-006 | T-07, T-15 | mock | CDR scenarios pass
- T-HUBJECT-29 | Notification handler for ErrorType and End-closes-session | ERR-007 | T-13 | mock | notification scenarios pass
- T-HUBJECT-30 | EVSE pull hardening (size, nulls, compatibility filter, subscription gating) | ERR-008, ERR-013 | T-16 | mock | EVSE scenarios pass
- T-HUBJECT-31 | OPCP error client (traceId logging, token refresh, retry classes) | ERR-010, ERR-011 | T-09, T-20 | mock | opcp-errors scenarios pass
- T-HUBJECT-32 | Webhook endpoint status policy and PCID lifecycle handlers | ERR-009, ERR-012 | T-18 | mock | webhook scenarios pass
- T-HUBJECT-33 | Failure-injection suite on the hub mock (every code in flows.md §1, every OPCP code) | ERR-001..013 | T-03, T-24 | mock | suite green in CI
- T-HUBJECT-34 | Send Q-ERR-1..9 to Hubject; update the mapping table and `@pending-confirmation` scenarios from the answers | ERR-001, AUTH-004 | none | none | answers recorded in the backlog

Blocked or deferred work is tracked in `../../analysis/backlog.md`.
