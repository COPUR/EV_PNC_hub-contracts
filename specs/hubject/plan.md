# Plan: Hubject connector

Builds the requirements in `spec.md` inside `EV_PNC_roaming-hubs` (`src/main/kotlin/.../hubject`), with ADR-0001 (adapters translate at the edge to the canonical OCPI-shaped model).

## Components

| Component | Responsibility | Requirements |
|---|---|---|
| `oicp-server` | Receives authorize start/stop, CDRs, notifications from the HBS; mTLS in; maps to canonical commands | AUTH-001..003, AUTH-006, CDR-001 |
| `oicp-client` | Sends remote start/stop, pulls EVSE data and status, pricing pull, optional auth-data push | CMD-001, LOC-001 |
| `oicp-identity` | ProviderID, certificate loading and rotation, environment selection, version declaration | SEC-001..004 |
| `opcp-mo-client` | PCP, RCP, CPS, CCP clients with OAuth2 JWT; contract lifecycle | PNC-001, PNC-002, PNC-004, PNC-005 |
| `mapping` | OICP ↔ canonical, generated tables where possible | CDR-001, LOC-001 |

## Design notes

- Generate typed clients and server stubs from the pinned contracts in `../../_sources/` (OpenAPI Generator or equivalent). Commit the pinned files; regenerate when `fetch_public_contracts.py` shows a diff.
- The authorize path must be fast (the HBS timeout value is still open, see the analysis backlog): keep policy decisions in memory or a read-through cache, no synchronous calls to slow dependencies.
- Idempotency: key CDRs by hub plus SessionID; the HBS can resend.
- Never log the QR PIN or tokens; clear-text PIN arrives in the authorize request by design.
- Plug&Charge keys: the encrypted contract private key and DH public key are produced by the PKI side (see ADR-0003); the connector only transports them.
- Run as an online EMP (ADR-0002), so skip authentication-data push in the pilot.
- Remote stop, notifications, dynamic pricing, webhooks and V2G-PKI enrolment wait on the deep analysis (`../../analysis/`).

## Test strategy

- `@mock`: hub mocks generated from the pinned OpenAPI files, run in CI.
- `@sandbox`: only against Hubject QA after onboarding; keep the list short and tagged.
