# Tasks: GIREVE connector

Format: `T-ID | title | requirements | depends on | environment | exit check`

- T-GIREVE-01 | Load the hub profile as typed configuration | REG-001..004, VER-001, TOK-003, CMD-002, TARIFF-002, LOC-001 | none | none | profile parses and drives the compatibility layer
- T-GIREVE-02 | OCPI 2.2.1 compatibility layer (down/up-convert) | VER-001 | ocpi-emsp canonical model, analysis WP5 | mock | version scenario passes
- T-GIREVE-03 | Registration automation against a mock IOP | REG-001..003 | T-01 | mock | registration scenarios pass on the mock
- T-GIREVE-04 | Routing and tracing middleware | REG-004 | T-02 | mock | header scenario passes
- T-GIREVE-05 | Token authorize endpoint and UID normalisation | TOK-001, TOK-003 | policy-engine API | mock | token scenarios pass
- T-GIREVE-06 | Selective token push (no EMAID, full PUTs) | TOK-002, TOK-004 | T-05 | mock | EMAID and PUT scenarios pass
- T-GIREVE-07 | START_SESSION through the hub | CMD-001, CMD-002 | T-04 | mock | command scenarios pass
- T-GIREVE-08 | Session and CDR ingest with replay safety | SESSION-001, CDR-001 | T-04 | mock | CDR scenario passes
- T-GIREVE-09 | Tariff and location ingest with GIREVE limits | TARIFF-002, LOC-001, LOC-002 | T-04 | mock | scenarios pass
- T-GIREVE-10 | eMAID authorize mapping | PNC-005 | T-05 | mock | scenario passes
- T-GIREVE-11 | PNCP OAuth2 identity and webhooks with HMAC verification | PNC-002, PNC-006 | none | mock | token-reuse and signature scenarios pass
- T-GIREVE-13 | Key and CSR rules (secp256r1, PKCS#10, new key on renewal) | PNC-003 | none | mock | renewal scenario passes
- T-GIREVE-12 | Secret handling and log redaction tests | SEC-001 | none | mock | redaction scenario passes

- T-GIREVE-14 | Apply v1.6 source update and profile patch | all | none | none | profile parses; URLs updated
- T-GIREVE-15 | Conversion layer from the conversion table | VER-002, VER-003, TOK-005 | T-02 | mock | conversion scenarios pass
- T-GIREVE-16 | Inbound mTLS and IP filter for IOP calls | SEC-002 | infra | mock | inbound-mtls passes
- T-GIREVE-17 | FromIOP registration endpoints and DELETE handling | REG-001, REG-005 | T-03 | mock, sandbox | register/unregister pass
- T-GIREVE-18 | Targeted tariff selection | TARIFF-001, TARIFF-003 | T-09 | mock | tariff scenarios pass
- T-GIREVE-19 | PNCP mTLS client (secure hosts, GTS Root R1) | PNC-002, PNC-008 | T-11 | mock | mtls passes
- T-GIREVE-20 | eMAID generator (Annex H.1, our party) | PNC-009 | TR party ID | none | format tests pass
- T-GIREVE-21 | Build Sign Store, Check PCID, Deactivate, renew | PNC-001, PNC-010, PNC-012, PNC-013, PNC-015 | PNCP OpenAPI export (blocked) | mock, sandbox | PNCP scenarios pass
- T-GIREVE-22 | Webhook handlers for SCCB events | PNC-004, PNC-011 | T-11 | mock | pc-changed, delivered pass
- T-GIREVE-23 | Session gap tolerance, no pull | SESSION-002 | T-08 | mock | session-gaps passes
- T-GIREVE-24 | Import GIREVE eMSP 2.2.1 certification tests | CERT-001 | person downloads .xlsx | none | every row mapped to a scenario
- T-GIREVE-25 | ISO 15118-2-only gate in activation UX | PNC-014 | app | mock | iso-version passes
- T-GIREVE-26 | Error mapping for tokens, commands, hub codes | ERR-001..005 | T-05, T-07 | mock | token/command scenarios pass
- T-GIREVE-27 | Pagination follower and pull client | ERR-006 | T-04 | mock | pagination passes
- T-GIREVE-28 | PNCP token lifecycle | ERR-007 | T-11, T-19 | mock | pncp-token-expired passes
- T-GIREVE-29 | CDR idempotency, self-pricing for [?] | ERR-008, ERR-009 | T-08 | mock | cdr scenarios pass
- T-GIREVE-30 | Driver messages per failure row (TR/EN/DE) | ERR-002..004, ERR-010 | app | mock | copy reviewed
- T-GIREVE-31 | Confirm GIREVE error codes, timeouts, webhook retries | (backlog) | GIREVE answers | none | U rows resolved

Blocked or deferred work is tracked in `../../analysis/backlog.md`.
