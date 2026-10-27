# Spec: e-clearing.net (ECHX) connector (eMSP role)

**Status:** draft from public sources, 2026-10-24 · **Baseline:** OCPI 2.3.0 eMSP, speaking 2.2.1 to ECHX · **Contracts:** `../../profiles/`
**Sources:** e-clearing.net changelog v3.0 (May 2025), starter package page, ECHX frontend manual v2.

## Scope

In: data-handling rules of the ECHX OCPI 2.2.1 interface, operations runbook items. The connector itself (handshake, routing, authorize) stays a discovery item until Q-EC-01..04 are answered.
Out: CPO role, OCHP and OCHPdirect (ADR-0004 proposed), NAP Access (CPO-only), Plug&Charge.

## Requirements

Build-ready only: fact-based, pilot priority. If the product decision moves e-clearing.net to Phase 5, change every priority to `later`. Unknowns are in `../../analysis/backlog.md`.

### RH-ECLEARING-VER-001
THE eMSP platform SHALL speak OCPI 2.2.1 to e-clearing.net ECHX; 2.3.0 is not offered.
- source: https://www.e-clearing.net/starter-package; https://www.e-clearing.net/changelog-summary-system-update (QA metadata paths 2.1.1, 2.2.1)
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-ID-001
WHEN storing or comparing Token UID, Tariff ID, Location ID, EVSE UID, Session ID or CDR ID received from ECHX THE eMSP platform SHALL treat them as case sensitive.
- source: https://www.e-clearing.net/changelog-summary-system-update "General Changes", "OCPI-Updates"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-ID-002
THE eMSP platform SHALL prefix its token UIDs and other IDs it originates with its own country code and party ID.
- source: https://www.e-clearing.net/changelog-summary-system-update (recommendation, example "DELND…")
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-LOC-001
WHEN paginating ECHX responses THE eMSP platform SHALL follow the `Link` header until it is empty and SHALL NOT rely on `X-Total-Count`.
- source: https://www.e-clearing.net/changelog-summary-system-update "OCPI Pagination"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-LOC-002
WHEN an ECHX location carries `-` in a mandatory field, has no time zone, or has an EVSE without `evse_id` THE eMSP platform SHALL accept it, treat `-` as not provided, mark the time zone as defaulted to UTC, and not show placeholders to drivers.
- source: https://www.e-clearing.net/changelog-summary-system-update "Fallbacks and defaults", "Locations without EVSE ID"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-LOC-003
WHEN ECHX delivers a terminated roaming location (delivered for 14 days) THE eMSP platform SHALL remove it from search and planning.
- source: https://www.e-clearing.net/changelog-summary-system-update "Metadata and API Access"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-TOK-001
WHEN the eMSP platform sends a PATCH to ECHX THE platform SHALL include list- and object-typed fields in full.
- source: https://www.e-clearing.net/changelog-summary-system-update "Patch requests"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-CDR-001
THE eMSP platform SHALL ingest ECHX CDRs and reconcile them against sessions well within the 35-day CDR retention, and SHALL alert when a CDR older than 25 days is unreconciled.
- source: https://www.e-clearing.net/changelog-summary-system-update (retention 35 days); the 25-day alert is our margin
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-CDR-002
WHEN an ECHX CDR references an unknown location (EVSE ID used in its place) THE eMSP platform SHALL accept the CDR and resolve it by EVSE ID.
- source: https://www.e-clearing.net/changelog-summary-system-update "Fallbacks and defaults"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-CMD-001
THE eMSP platform SHALL treat `authorization_reference` from ECHX as opaque; it may carry an OCHPdirect DirectID.
- source: https://www.e-clearing.net/changelog-summary-system-update "Command Mapping"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-CMD-002
THE eMSP platform SHALL NOT send ChargingProfiles through ECHX.
- source: https://www.e-clearing.net/changelog-summary-system-update "Charging Profiles: Not implemented yet in 2.2.1"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-data-rules.feature

### RH-ECLEARING-OPS-001
WHEN roaming connections, credentials, networks or users are changed in ECHX THE operations runbook SHALL wait up to 2 minutes before verifying.
- source: https://www.e-clearing.net/changelog-summary-system-update
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: runbook check (no Gherkin)

### RH-ECLEARING-REG-001
WHEN requesting a roaming connection in ECHX THE operator SHALL set a future start date and SHALL expect the partner's approval for any change.
- source: https://www.e-clearing.net/frontendmanual-echx-v2 §Roaming Connections
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: runbook check (no Gherkin)

### RH-ECLEARING-REG-002
BEFORE accepting a Charge Club offer THE eMSP SHALL be on the ECHX productive system with complete network contact details, and SHALL record that cancellation takes effect one month after the request.
- source: https://www.e-clearing.net/frontendmanual-echx-v2 §Charge Club
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: runbook check (no Gherkin)

**Note on ERR-001..005:** the OCPI status codes and command values are quoted from the OCPI 2.3.0 text (COPUR/ocpi); ECHX speaks 2.2.1. Confirm against the 2.2.1 text in WP5 before release (backlog INF-5).

### RH-ECLEARING-ERR-001
WHEN the hub forwards a real-time authorization for a token the eMSP does not know THE eMSP platform SHALL answer with OCPI `status_code` 2004 and no `data` field.
- source: COPUR/ocpi (OCPI 2.3.0) mod_tokens.asciidoc POST authorize, response data (2.3.0 text; 2004 in 2.2.1 not re-checked)
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/acceptance/echx-error-flows.feature

### RH-ECLEARING-ERR-002
WHEN a real-time authorization carries no LocationReferences and the eMSP cannot decide THE eMSP platform SHALL answer with OCPI `status_code` 2002.
- source: COPUR/ocpi (OCPI 2.3.0) mod_tokens.asciidoc
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-error-flows.feature

### RH-ECLEARING-ERR-003
WHEN a START_SESSION or STOP_SESSION CommandResponse is NOT_SUPPORTED, REJECTED or UNKNOWN_SESSION, or a CommandResult is anything other than ACCEPTED, THE eMSP platform SHALL treat the command as not started and SHALL NOT retry it automatically.
- source: COPUR/ocpi (OCPI 2.3.0) mod_commands.asciidoc CommandResponseType, CommandResultType; "OCPI does not allow/require retries"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-error-flows.feature

### RH-ECLEARING-ERR-004
WHEN no CommandResult arrives within the `timeout` seconds returned in the CommandResponse THE eMSP platform SHALL stop waiting, SHALL check the session list, and SHALL report the outcome as unconfirmed if no session exists.
- source: COPUR/ocpi (OCPI 2.3.0) mod_commands.asciidoc CommandResponse.timeout
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-error-flows.feature

### RH-ECLEARING-ERR-005
WHEN a POST, PUT or PATCH to the hub fails or times out THE eMSP platform SHALL NOT queue it for later replay, and WHEN the connection is back SHALL resynchronise by GET (locations, CDRs by time window).
- source: COPUR/ocpi (OCPI 2.3.0) transport_and_format.asciidoc Offline behaviour ("SHOULD NOT be queued")
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-error-flows.feature

### RH-ECLEARING-ERR-006
THE eMSP platform SHALL remove duplicate values from every list field before sending it to ECHX, because legacy eCHS rejects duplicates.
- source: https://www.e-clearing.net/changelog-summary-system-update "General Changes, Duplicates"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-error-flows.feature

### RH-ECLEARING-ERR-007
THE eMSP platform SHALL send Token UID, Tariff ID, Location ID, EVSE UID, Session ID and CDR ID with exactly the stored case.
- source: https://www.e-clearing.net/changelog-summary-system-update "General Changes, Case sensitivity"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-error-flows.feature

### RH-ECLEARING-ERR-008
WHEN a Charge Club cancellation is requested or received THE operator SHALL record termination date = request date + one month, and the platform SHALL hide that CPO's locations when delivery stops.
- source: https://www.e-clearing.net/frontendmanual-echx-v2 §6 "fully terminated one month after the cancellation request"; https://www.e-clearing.net/changelog-summary-system-update "terminated roaming locations are delivered for 14 days"
- confidence: fact
- priority: pilot
- contract: ../../profiles/e-clearing-echx-ocpi-2.2.1.profile.yaml
- verify: acceptance/echx-error-flows.feature
