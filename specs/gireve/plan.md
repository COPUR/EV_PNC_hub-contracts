# Plan: GIREVE connector

## Components

| Component | Responsibility | Requirements |
|---|---|---|
| `ocpi221-compat` | Down-convert canonical 2.3.0 objects to 2.2.1 for GIREVE; up-convert inbound | VER-001 |
| `iop-registration` | Registration runbook and automation, certificate and IP configuration | REG-001..004 |
| `iop-router` | OCPI-to/from headers, request and correlation ids, store-and-forward for outbound | REG-004, SESSION-001 |
| `token-sync` | Real-time authorize, selective push, UID normalisation | TOK-001..004 |
| `tariff-locations` | GIREVE limits, ad hoc fallback, Plug&Charge capability read | TARIFF-*, LOC-* |
| `pncp-client` | OAuth2 identity, webhooks now; pools and contract lifecycle after WP2 | PNC-002, PNC-005, PNC-006 |

## Design notes

- The profile in `../../profiles/gireve-ocpi-2.2.1.profile.yaml` is the single source for hub rules; load it as configuration so a guide revision is a data change.
- The base OCPI 2.2.1 spec is not a GIREVE contract file; keep OCPI 2.2.1 schemas from the published OCPI release (`COPUR/ocpi` releases) for validation.
- PNCP and OPCP share concepts; both talk to `plugcharge` through one port (see `../adr/0003`).
- The guest-tariff gap (TARIFF-001) needs a product decision before building; it is a deep-analysis item.
- The PNCP REST client waits for the endpoint list (not captured in the public read); webhooks and eMAID authorize can be built now.
