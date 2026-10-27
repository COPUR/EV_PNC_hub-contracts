# Tasks: e-clearing.net connector

Format: `T-ID | title | requirements | depends on | environment | exit check`

- T-EC-01 | Add ECHX profile to the 2.2.1 compatibility layer | VER-001, CMD-001, CMD-002 | WP5 | mock | profile loaded; version test green
- T-EC-02 | Case-sensitive ID store and prefixing | ID-001, ID-002 | T-EC-01 | mock | scenarios green
- T-EC-03 | Location ingestion rules (placeholders, UTC, null evse_id, terminated) | LOC-001..003 | T-EC-01 | mock | scenarios green
- T-EC-04 | Full-object PATCH builder | TOK-001 | T-EC-01 | mock | scenario green
- T-EC-05 | CDR ingestion, 35-day reconciliation alert, EVSE fallback | CDR-001, CDR-002 | T-EC-01 | mock | scenarios green
- T-EC-06 | ECHX registration and routing | (backlog REG-003) | **blocked: Q-EC-01..03** | hub sandbox | handshake on QA
- T-EC-07 | Guest and app authorization via ECHX | (backlog TOK-002) | **blocked: Q-EC-04, 13** | hub sandbox | decision recorded
- T-EC-08 | ECHX ops runbook (connections, Charge Club, 2-minute wait, support channels) | OPS-001, REG-001, REG-002 | none | none | runbook reviewed
- T-EC-09 | Mock ECHX hub from the profile | all mock tags | T-EC-01 | mock | mock serves pages with Link and `-` fields
- T-EC-10 | Authorize responder: 2004, 2002, AllowedType values | ERR-001, ERR-002 | T-EC-01 | mock | scenarios green
- T-EC-11 | Command lifecycle: response/result handling, timeout watchdog | ERR-003, ERR-004 | T-EC-01 | mock | scenarios green
- T-EC-12 | Outage handling and resync-by-GET job | ERR-005 | T-EC-03 | mock | scenario green
- T-EC-13 | Outbound dedupe and exact-case guard | ERR-006, ERR-007 | T-EC-02 | mock | scenarios green
- T-EC-14 | Charge Club and connection register (requests, start dates, termination date) | ERR-008, REG-001, REG-002 | T-EC-08 | none | register reviewed; scenario green
- T-EC-15 | Failure-injection mode in the mock hub (5xx, timeouts, partial pages, empty Link) | ERR-004, ERR-005 | T-EC-09 | mock | mock injects each failure
- T-EC-16 | ECHX error-code map | (backlog) | **blocked: Q-EC-17, 18** | hub sandbox | table filled from hub answers
- T-EC-17 | Authorization policy for OCHP-only CPOs | (backlog) | **blocked: Q-EC-04, 05** | hub sandbox | decision recorded
- T-EC-18 | CDR decline/revise/duplicate handling over OCPI | (backlog) | **blocked: Q-EC-06, 19** | hub sandbox | decision recorded
