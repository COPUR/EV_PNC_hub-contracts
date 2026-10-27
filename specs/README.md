# Spec bundle

Moved here on 2026-10-27 from the project files (`roaming-hubs/specs/`), with paths rewritten to this repository's layout.

| Path | Content |
|---|---|
| `hubject/` | OICP 2.3 EMP and OPCP MO requirements, plan, data model, tasks, Gherkin |
| `gireve/` | OCPI 2.2.1 via the IOP and PNCP requirements, plan, tasks, Gherkin |
| `e-clearing/` | ECHX (OCPI 2.2.1) requirements and Gherkin; phase 5 |
| `adr/` | ADR-0001 translate at the edge, 0002 Hubject online EMP, 0003 one Plug&Charge port, 0004 ECHX OCPI only, 0005 asymmetric parallel hubs, 0006 guest pricing |
| `traceability.csv` | requirement, source, contract, acceptance, task, status |

The profiles the requirements point at are in `../profiles/`, the pinned vendor files in `../_sources/`.

Requirement ids: `RH-<HUB>-<AREA>-<NNN>`. A change that adds or removes a requirement must change `traceability.csv` in the same commit (`tests/test_specs.py` fails otherwise).

## Status after the decision of 2026-10-27

The first emails to Hubject and GIREVE (TR-13, TR-14) will not be sent. Consequences for this bundle:

- Questions that were to go to the hubs (Hubject Q-ERR-1..9, GIREVE error codes, timeouts, webhook retries, the PNCP OpenAPI export) stay open. Scenarios tagged `@pending-confirmation` keep their inferred expectations; the authorize StatusCode mapping in `../profiles/hubject-authorize-statuscode.mapping.yaml` is `inference`.
- Requirements and tasks that need a hub contract or sandbox (`@sandbox`, certification, live tests) stay blocked; the adapters are built and tested against mocks derived from the pinned contracts.
- ADR-0005 (asymmetric parallel hubs) is not edited here. ADR-0018 in EV_PNC_hub-gateway (`docs/adr/0018-emsp-hub-adapter-framework.md`) proposes how to read it now that the commercial steps are dropped.
