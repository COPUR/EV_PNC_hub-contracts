# EV_PNC_hub-contracts

Hub specs and contracts for Hubject, GIREVE and e-clearing.net: requirements, profiles, conversion tables, Gherkin conformance features, pins and drift checks. Data only, no runtime code.

Part of the **EV_PNC** platform: a neutral eMSP integration layer for Turkey-first, Europe-ready Plug&Charge, navigation and payments. The platform is neither a CPO nor a payment institution.

> Plug in, charging starts, payment completes in the background.

## Scope

- Requirements RH-<HUB>-<AREA>-NNN, traceability, backlog of unknowns
- Profiles (GIREVE OCPI 2.2.1, ECHX), OCPI 2.3.0 to 2.2.1 conversion table, AsyncAPI for PNCP/OPCP events
- Gherkin features tagged @mock (CI) and @sandbox (hub test access)
- Pinned vendor contracts (OICP 2.3, OPCP): CC BY-SA 4.0, attribute; keep hashes and the fetch script, regenerate, never hand-edit
- Drift check in CI (T-HUBJECT-01)

## Tech stack

YAML, OpenAPI, AsyncAPI, Gherkin, Python (fetch and traceability scripts)

## Packaging

- Published components: hub-contracts
- Depends on: nothing outside this repo
- Depended on by: EV_PNC_hub-gateway, EV_PNC_simulator
- Dependency rules: no cycles (ADP); depend towards more stable components (SDP); published `*-api` components hold abstractions, deployables hold concrete code (SAP). CI runs `tools/packaging_check.py --strict` from `EV_PNC_docs`.
- Owner: Architect agent + QA agent · Wave 1 (now, before the 2026-12-07 gate) · Visibility: public

## Proposed layout

```
hubject/ gireve/ e-clearing/
_sources/ (pinned, CC BY-SA 4.0)
traceability.csv
```

## Related

- Plan: `repo-plan/v2/README.md` (project files); consent repos: `EV_PnC_Consent_*` (`repo-plan/consent/README.md`)
- Docs: [EV_PNC_docs](https://github.com/COPUR/EV_PNC_docs)

## Status

Scaffold only. Not production ready.

## License

Apache-2.0 (proposed)
