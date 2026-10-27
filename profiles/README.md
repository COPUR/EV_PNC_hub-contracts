# Hub profiles

Hub rules as data (ADR-0001). A profile records how one hub deviates from the standard it
speaks. Services load these files; they do not hard-code hub behaviour. The files are
overlays on the pinned contracts in `_sources/`, not schemas.

| File | Hub and role | Used by |
|---|---|---|
| `hubject-oicp-2.3-emp.profile.yaml` | Hubject OICP 2.3, eMSP (EMP) | simulator Hubject mock (H-03), hub-gateway (H-05) |
| `hubject-opcp-events.asyncapi.yaml` | Hubject OPCP webhook events | simulator Hubject mock |
| `gireve-ocpi-2.2.1.profile.yaml` | GIREVE IOP, OCPI 2.2.1 deviations | hub-gateway profile loader (H-02), simulator GIREVE mock (H-04) |
| `gireve-pncp-1.2.0.profile.yaml` | GIREVE trust platform PNCP 1.2.0 | hub-gateway (H-11) |
| `gireve-pncp-events.asyncapi.yaml` | GIREVE PNCP webhook events | simulator GIREVE mock |
| `ocpi-2.3.0-to-2.2.1.conversion.yaml` | canonical OCPI 2.3.0 to 2.2.1 as GIREVE speaks it | hub-gateway compatibility layer (H-02) |

Every entry carries a `source` and a `confidence` (`fact`, `inference`, `unknown`). Moving
an entry from `unknown` or `inference` to `fact` needs a source in the same commit.

## Licence and provenance

- The Hubject files summarise `hubject/oicp` and `hubject/opcp` (CC BY-SA 4.0, Hubject GmbH)
  and the Hubject support pages. They are adapted material and carry the same licence.
- The GIREVE files summarise GIREVE's public implementation guides in our own words; no
  guide text is copied. Treat them as ours, and re-check against the guide when it moves.
- The conversion table was generated from a table diff of OCPI 2.2.1 and 2.3.0. OCPI is
  CC BY-ND 4.0, so the table holds names, types and mapping rules only, never spec text.

## History

Moved here on 2026-10-27 from the project files (`roaming-hubs/specs/*/contracts/`). One edit:
the Hubject profile's `contract:` path now points at `../_sources/`, and a local path in the
conversion header became `COPUR/ocpi`.
