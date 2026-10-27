# Spec: Hubject connector (eMSP / EMP role)

**Status:** draft from public sources, 2026-10-24 · **Baseline:** OCPI 2.3.0 eMSP · **Contracts:** `../../profiles/` and `../../_sources/`
**Licence note:** requirements below summarise OICP 2.3 and OPCP 1.0.0 (CC BY-SA 4.0, Hubject). Derived contract files keep that licence and attribution.

## Scope

In: OICP 2.3 EMP role, OPCP mobility-operator role (Plug&Charge contract certificates), mapping to the platform's canonical OCPI-shaped model.
Out: CPO role, Hubject Financial Services, OICP 2.2 and earlier, ISO 15118-20 (OPCP 1.0.0 prepares it, no spec yet), SOAP.

## Actors

eMSP (us, EMP/MO) · Hubject HBS · CPO · OEM · Vehicle · Ecosystem operator (Hubject) · CPS operator.

## Non-goals and boundaries

Do not hold funds or act as a payment institution. Do not call QA or production endpoints during analysis; implementation tests start on mocks built from the pinned contracts.

## Requirements

Build-ready only: fact-based, pilot priority. Unknowns, inferences and later items are in `../../analysis/backlog.md`.


### RH-HUBJECT-SEC-001
WHEN the connector calls any HBS endpoint THE eMSP SHALL present a client certificate whose identity matches the ProviderID used in the request.
- source: https://raw.githubusercontent.com/hubject/oicp-emp-2.3-api-doc/master/src/info.yaml (line "Hubject compares the given Provider- or OperatorID to the partner's SSL client certificate"), OICP 2.2 EMP PDF §2.7
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml
- verify: acceptance/oicp-security.feature

### RH-HUBJECT-SEC-002
WHEN an OICP request has a ProviderID or OperatorID that does not match the caller's certificate THE HBS returns status 017, AND THE connector SHALL treat it as a configuration error, not a retryable one.
- source: OICP 2.2 EMP PDF §2.7
- confidence: fact (behaviour), inference (retry classification)
- priority: pilot
- verify: acceptance/oicp-security.feature

### RH-HUBJECT-SEC-003
THE connector SHALL target the QA base URL `https://service-qa.hubject.com/api/oicp` before production `https://service.hubject.com/api/oicp`, selected by configuration.
- source: OICP 2.3 EMP OpenAPI `servers`
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml
- verify: acceptance/oicp-security.feature

### RH-HUBJECT-AUTH-001
WHEN the HBS posts an authorize-start request THE eMSP SHALL answer with ProviderID, AuthorizationStatus (Authorized or NotAuthorized) and a StatusCode.
- source: OICP 2.3 EMP OpenAPI `/charging/v21/operators/{operatorID}/authorize/start` (RECEIVE, MANDATORY)
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml
- verify: acceptance/oicp-authorize.feature

### RH-HUBJECT-AUTH-002
WHEN the identification is RFID and the token does not belong to the eMSP THE eMSP SHALL answer NotAuthorized, because the HBS broadcasts RFID requests to every EMP under contract with the CPO.
- source: OICP 2.3 EMP OpenAPI description of eRoamingAuthorizeStart option (c)
- confidence: fact (broadcast), inference (answer rule)
- priority: pilot
- verify: acceptance/oicp-authorize.feature

### RH-HUBJECT-AUTH-006
THE eMSP SHALL store the HBS-generated SessionID from the first authorize or remote-start exchange and echo it on all later requests of that session.
- source: OICP 2.2 EMP PDF §2.6
- confidence: fact
- priority: pilot
- verify: acceptance/oicp-authorize.feature

### RH-HUBJECT-CMD-001
WHEN a driver starts a session from the app at a Hubject-roamed EVSE THE eMSP SHALL call authorize-remote/start with SessionID, ProviderID, EvseID and Identification and treat Result=false as a failed start.
- source: OICP 2.3 EMP OpenAPI (SEND, MANDATORY)
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml
- verify: acceptance/oicp-remote-start-cdr.feature

### RH-HUBJECT-CDR-001
WHEN the HBS posts a charge-detail-record THE eMSP SHALL acknowledge with Result and StatusCode, persist the record idempotently by SessionID, and map it to the canonical CDR.
- source: OICP 2.3 EMP OpenAPI `/cdrmgmt/v22/.../charge-detail-record` (RECEIVE, MANDATORY)
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml
- verify: acceptance/oicp-remote-start-cdr.feature

### RH-HUBJECT-CDR-002
THE eMSP SHALL compute the session price itself because the OICP CDR contains no monetary fields (energy, times, meter values, signed metering and calibration info only).
- source: OICP 2.3 EMP OpenAPI CDR request schema
- confidence: fact (schema), inference (pricing path)
- priority: pilot
- verify: acceptance/oicp-remote-start-cdr.feature

### RH-HUBJECT-LOC-001
THE eMSP SHALL pull EVSE data with eRoamingPullEvseData (v2.3) and EVSE status with eRoamingPullEvseStatus (v2.1) and map them to canonical Locations, EVSEs and Connectors.
- source: OICP 2.3 EMP OpenAPI
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml
- verify: acceptance/oicp-evse-data.feature

### RH-HUBJECT-PNC-001
WHEN a customer registers a vehicle THE eMSP SHALL fetch its provisioning certificate with getOEMProvCert(pcid) and validate the chain against OEM roots from the RCP before issuing a contract.
- source: OPCP 1.0.0 02_PnC_business-processes.md, pcp.v1.json, rcp.v1.json
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-opcp-pcp.mo.openapi.json; ../../_sources/hubject-opcp-rcp.mo.openapi.json
- verify: acceptance/opcp-contract-provisioning.feature

### RH-HUBJECT-PNC-002
WHERE the eMSP operates its own PKI THE eMSP SHALL submit contract data (certificate chain, DH public key, encrypted private key, EMAID, PCID) to the CPS, using createSignedContractData or createAndForwardSignedContractData.
- source: OPCP cps.v1.json, 03_certificate-provisioning-service.md
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-opcp-cps.mo.openapi.json
- verify: acceptance/opcp-contract-provisioning.feature

### RH-HUBJECT-PNC-004
THE eMSP SHALL keep contracts per PCID in the CCP (several EMAIDs per vehicle allowed), mark one as default for offline installation, renew by overwriting the same EMAID, and delete by EMAID.
- source: OPCP ccp.v1.json, 04_contract-certificate-pool.md
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-opcp-ccp.mo.openapi.json
- verify: acceptance/opcp-contract-provisioning.feature

### RH-HUBJECT-PNC-005
THE eMSP SHALL authenticate to OPCP services with OAuth2 and a JWT scoped to its EMAID prefix (country code plus provider ID); calls for other prefixes SHALL be refused by the ecosystem and treated as configuration errors.
- source: OPCP 04_authentication.md
- confidence: fact
- priority: pilot
- verify: acceptance/opcp-contract-provisioning.feature

### RH-HUBJECT-PNC-007
WHEN a Plug&Charge authorize arrives with PlugAndChargeIdentification THE eMSP SHALL derive the contract from the EvcoID (the EMAID) and answer as in RH-HUBJECT-AUTH-001.
- source: OICP 2.2 EMP PDF §3.1.1 option b; OICP 2.3 schema PlugAndChargeIdentification
- confidence: fact
- priority: pilot
- verify: acceptance/oicp-authorize.feature

### RH-HUBJECT-AUTH-003
WHEN the identification carries an EvcoID (QR code, Plug&Charge, remote) THE eMSP SHALL resolve the contract from the EvcoID and apply the same policy decision (price threshold, operator allow and block lists) used for OCPI and app sessions.
- source: OICP 2.3 EMP OpenAPI (option b); project goal "Policy Filtering"
- confidence: project requirement (Policy Filtering goal); hub fact: EvcoID routing
- priority: pilot
- verify: acceptance/oicp-authorize.feature

### RH-HUBJECT-AUTH-004
WHEN the HBS posts authorize-start THE eMSP SHALL return the eRoamingAuthorizationStart response within 10 s of receipt, AND IF the policy decision cannot complete within the internal budget THEN the connector SHALL answer NotAuthorized with StatusCode 021 rather than exceed 10 s.
- source: https://support.hubject.com/hc/en-us/articles/4403421095953 ("within 10 seconds otherwise … time-out"); oicp-emp-2.3-api-doc@9a773b3 authorize/start option b (unreachable = NotAuthorized)
- confidence: fact (10 s), inference (021 fallback)
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml; ../../profiles/hubject-oicp-2.3-emp.profile.yaml#timeouts
- verify: acceptance/oicp-authorize.feature#timeout-budget

### RH-HUBJECT-CMD-002
WHEN a driver stops a Hubject-roamed session from the app THE eMSP SHALL POST `/charging/v21/providers/{ProviderID}/authorize-remote/stop` with SessionID, ProviderID and EvseID, using our ProviderID as the path value the pinned contract calls `externalID`.
- source: OICP23_Integration_Guide@68e8710:03_Services/Services Implementation for EMPs/05-eRoamingAuthorizeRemoteStop.md:35-40 (leading document, README:5); oicp@119c5d5:OICP-2.3/OICP 2.3 EMP/02_EMP_Services_and_Operations.asciidoc:251-255
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml; ../../profiles/hubject-oicp-2.3-emp.profile.yaml#paths_extra
- verify: acceptance/oicp-remote-stop-notifications.feature

### RH-HUBJECT-CDR-003
WHERE charging notifications are enabled in Service Type Settings, WHEN the HBS forwards a Start, Progress, End or Error notification THE eMSP SHALL answer eRoamingAcknowledgement (Result, StatusCode), update the session, AND on End SHALL close the session even if no CDR follows.
- source: oicp@119c5d5:…/02_EMP_Services_and_Operations.asciidoc:829-852; OICP23_Integration_Guide@68e8710:03_Services/Services Implementation for CPOs/06-eRoamingChargingNotifications-End.md:88-92; support article 4403420365585
- confidence: fact (direction, ack); inference (close-on-End rule)
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml `/notificationmgmt/v11/charging-notifications`
- verify: acceptance/oicp-remote-stop-notifications.feature

### RH-HUBJECT-SEC-004
THE connector SHALL declare to Hubject the OICP version it runs (2.3) AND SHALL call only service versions of an active OICP version (each version is supported for two years).
- source: oicp-emp-2.3-api-doc@9a773b3:src/info.yaml:51, :63
- confidence: fact
- priority: pilot
- verify: acceptance/oicp-security.feature#version

### RH-HUBJECT-PNC-006
WHEN an OPCP webhook arrives THE eMSP SHALL compute HMAC-SHA256 over the raw body with the endpoint secret, compare it in constant time with the hex value after `sha256=` in `X-Hubject-Signature`, `X-Operator-Signature` or `payload-signature` (whichever is present), AND SHALL reject the request with HTTP 400 when no header matches.
- source: opcp@de066c8:OPCP-1.0.0/docs/components/06_webhook-service.md:57, :73-88, :109-153, :226-227; reference/webhook.payload.v1.json
- confidence: fact (algorithm); conflict (header name, signing marked optional): open question Q-HUBJECT-WH-1
- priority: pilot
- contract: ../../profiles/hubject-opcp-events.asyncapi.yaml
- verify: acceptance/opcp-webhooks.feature

### RH-HUBJECT-CERT-001
BEFORE production THE eMSP SHALL pass Hubject's EMP E2E test in QA against the Virtual Charging Point (case 1 or 2 RFID Classic or DESFire, case 3 remote start from the app, case 4 wrong credential refused), have the E2E protocol approved, pass the live E2E test, and repeat the E2E test in PROD.
- source: https://support.hubject.com/hc/en-us/articles/4403432482321; …/11906803615773; OICP23_Integration_Guide@68e8710:01_Overview/03-Testing the Implementation/Description-and-limitations-of-remote-testing-tools-and-VCP.md:26-39
- confidence: fact
- priority: pilot
- verify: acceptance/oicp-onboarding.feature

### RH-HUBJECT-CMD-003
WHEN sending authorize-remote/start THE eMSP SHALL omit SessionID, SHALL store the SessionID returned by the HBS, AND SHALL use a client timeout of at least 65 s for both remote start and remote stop.
- source: oicp@119c5d5:…/02_EMP_Services_and_Operations.asciidoc:224; support 4403421095953 (CPO 40 s); OICP23_Integration_Guide@68e8710:…/05-eRoamingAuthorizeRemoteStop.md:14-16 (CPO 60 s)
- confidence: fact (SessionID, CPO windows); inference (client timeouts)
- priority: pilot
- verify: acceptance/oicp-remote-start-cdr.feature#no-session-id

### RH-HUBJECT-CDR-004
THE eMSP SHALL run a reconciliation job at least daily that calls GetChargeDetailRecords (v2.2, paginated, `CDRForwarded=false`, per date range) and ingests missing CDRs idempotently, because the HBS does not resend failed CDRs.
- source: support 4403421095953 ("the CDR will not be resent"); oicp@119c5d5:OICP-2.3/Realease_Notes.asciidoc:65-79; …/02_EMP_Services_and_Operations.asciidoc:281-283, :333-347
- confidence: fact (behaviour), inference (daily)
- priority: pilot
- verify: acceptance/oicp-cdr-reconciliation.feature

### RH-HUBJECT-LOC-003
WHEN pulling EVSE data THE connector SHALL page with `page` and `size` (size ≤ 2000) until `last=true`, SHALL run a full pull daily and MAY run `LastCall` delta pulls in between, never combined with `SearchCenter`.
- source: oicp-emp-2.3-api-doc@9a773b3:src/resources/eRoamingData/eRoamingPullEvseData_V2.3.yaml:15-29; OICP23_Integration_Guide@68e8710:…/00-Pagination.md:8-10, 01-eRoamingPullEvseData.md:150-189
- confidence: fact
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-evse-data.feature#pagination

### RH-HUBJECT-LOC-004
THE connector SHALL pull EVSE status every 3-5 minutes, preferring `status-records-by-operator-id` for subscribed CPOs, within the AUP limits.
- source: OICP23_Integration_Guide@68e8710:…/02-eRoamingPullEvseStatus.md:73-74, 03-PullEvseStatus by OperatorID.md:7-29; support 4403421095953 (2-3 min); AUP v1-0:156-217
- confidence: fact (endpoints, limits), inference (interval within the conflict)
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-evse-data.feature#status-by-operator

### RH-HUBJECT-OPS-002
THE connector SHALL throttle each OICP and NGP operation below the AUP per-minute limits (PullEVSEData at 25 until confirmed), AND WHEN it receives HTTP 429 SHALL retry with exponential backoff and jitter.
- source: oicp@119c5d5:Hubject Acceptable Use Policy v1-0.asciidoc:104-217; support 4403421095953; NGP-Automation-APIs@2b385b9:EMP/v1 asciidoc :19, :22
- confidence: fact
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-rate-limits.feature

### RH-HUBJECT-OPS-003
THE platform SHALL NOT call Hubject APIs for health checks, SHALL NOT run load or security tests against PROD, AND SHALL run them on QA only with Hubject's written approval.
- source: AUP v1-0:38-41, :87-102
- confidence: fact
- priority: pilot
- verify: runbook review (no automated test)

### RH-HUBJECT-SEC-005
THE platform SHALL egress to Hubject from static IP addresses registered in the Tech questionnaire AND SHALL accept inbound HBS calls only from Hubject's published QA and PROD source IPs, configured per environment.
- source: OICP23_Integration_Guide@68e8710:01_Overview/02-Getting Started/04-Pre-requisites.md:8-10; support 11906803615773 (IP list); support 4403415530897
- confidence: fact
- priority: pilot
- verify: acceptance/oicp-security.feature#ip-allowlist (@sandbox)

### RH-HUBJECT-SEC-006
THE platform SHALL generate separate QA and PROD CSRs with `O=Hubject` and `CN=` the service domain, SHALL use the Hubject-signed certificates as the OICP client identity, AND SHALL trust the Hubject root CA for inbound HBS calls (or upload a user certificate as .pem or .crt).
- source: support 4403416095889; OICP23_Integration_Guide@68e8710:01_Overview/02-Getting Started/05-Certificate-Management.md:4-12; support 4403778169745
- confidence: fact
- priority: pilot
- verify: acceptance/oicp-security.feature#csr

### RH-HUBJECT-REG-001
THE platform SHALL use one Provider ID of the form `TR` + 3 alphanumeric characters (ISO form, optional separator) in all OICP calls and EMAIDs, AND SHALL obtain Hubject's uniqueness confirmation before onboarding, because no Turkish issuing authority is listed.
- source: support 4403415384465 (country list, self-selection rule); oicp@119c5d5:OICP-2.3/OICP 2.3 EMP/03_EMP_Data_Types.asciidoc:858-870 (ProviderIDType)
- confidence: fact (rule); unknown (whether EPDK will issue IDs, Q-TR-ID)
- priority: pilot
- verify: onboarding checklist

### RH-HUBJECT-REG-002
WHEN configuring each environment in the HBS portal THE operator SHALL enable Online Requests and Broadcast Requests for Authorization and Online Requests for Charging Notification, and set the service URLs.
- source: support 4403420365585
- confidence: fact
- priority: pilot
- verify: acceptance/oicp-onboarding.feature#portal-flags (@sandbox)

### RH-HUBJECT-CERT-002
BEFORE the QA phase THE eMSP SHALL provide test RFID cards (Classic or DESFire) and submit their UIDs to Hubject.
- source: support 4403400945041 (phase 1: send RFID UIDs); support 4403432482321 (cases 1-2)
- confidence: fact
- priority: pilot
- verify: acceptance/oicp-onboarding.feature

### RH-HUBJECT-TARIFF-001
THE eMSP SHALL pull the NGP Enhanced Contracts API and Contracts EVSEs API for every subscribed CPO, map tariffs per EVSE group and time slot (excluding taxes) to canonical B2B tariffs, AND SHALL use them as the cost input for price policy decisions at authorize time and for guest pricing.
- source: NGP-Automation-APIs@2b385b9:NGPAutomationAPIs/EMP/v1/1. Enhanced Contracts API.asciidoc, 2. Contracts EVSEs API.asciidoc, contracts openapi-spec_v1.json; support 10514546831261
- confidence: fact (API, components); project requirement (policy filtering)
- priority: pilot
- contract: proposed pin `_sources/hubject-ngp-contracts.emp.openapi.json`
- verify: acceptance/oicp-ngp-tariffs.feature

### RH-HUBJECT-PNC-008
WHEN an OPCP webhook is valid THE eMSP SHALL answer 2xx quickly and process it idempotently by `eventId`, AND on `mo.prov.cert.deleted`, `mo.prov.cert.updated` or `mo.prov.cert.factory.reset` SHALL mark that PCID's contracts invalid, stop creating contracts for it, and notify the customer; on `root.cert.revoked` SHALL alert operations.
- source: opcp@de066c8:OPCP-1.0.0/docs/components/06_webhook-service.md:17-34, :48
- confidence: fact (events, retries); inference (handling)
- priority: pilot
- contract: ../../profiles/hubject-opcp-events.asyncapi.yaml
- verify: acceptance/opcp-webhooks.feature

### RH-HUBJECT-PNC-009
THE OPCP client SHALL take region, stage (`plugncharge-test`, `plugncharge-qa`, `plugncharge`) and domain from configuration.
- source: opcp@de066c8:OPCP-1.0.0/docs/00_versioning.md:138-152
- confidence: fact
- priority: pilot
- verify: acceptance/opcp-contract-provisioning.feature#environment

### RH-HUBJECT-PNC-010
BEFORE calling OPCP MO services THE eMSP SHALL have its EMAID prefix (`TR` + ProviderID) registered with the ecosystem operator, AND SHALL normalise EMAIDs to upper case without separators.
- source: opcp@de066c8:OPCP-1.0.0/docs/04_authentication.md:20-21; 05_handling-of-ids.md:62-63
- confidence: fact
- priority: pilot
- verify: acceptance/opcp-contract-provisioning.feature#emaid-normalisation

### RH-HUBJECT-ERR-001
THE eMSP SHALL include a StatusCode whose `Code` comes from the official OICP 2.3 list in every authorization, acknowledgement and notification response, SHALL put free-text reasons only in `AdditionalInfo` (≤ 1000 characters), AND SHALL use `Description` only with defined values.
- source: oicp@119c5d5:OICP-2.3/OICP 2.3 EMP/01_EMP_Communication_Paradigms.asciidoc:32-40; 03_EMP_Data_Types.asciidoc:588-624; oicp-emp-2.3-api-doc@9a773b3:src/schemas/StatusCode.yaml:10-50
- confidence: fact
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml
- verify: acceptance/oicp-errors.feature

### RH-HUBJECT-ERR-002
WHEN an OICP response arrives with HTTP 200 THE connector SHALL decide success or failure from `Result` or `AuthorizationStatus` and `StatusCode.Code`, not from the HTTP status, AND SHALL treat HTTP 429 and other non-200 statuses as transport failures.
- source: oicp-emp-2.3-api-doc@9a773b3:src/resources/** (only `200` declared); oicp@119c5d5:Hubject Acceptable Use Policy v1-0.asciidoc:136-149 (429)
- confidence: fact (declared codes, 429)
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-errors.feature

### RH-HUBJECT-ERR-003
WHEN the connector receives StatusCode `017` THE connector SHALL classify it as a certificate or ProviderID configuration error, SHALL NOT retry automatically, AND SHALL alert; AND the platform SHALL monitor the expiry of the Hubject-signed client certificate (about 2 years for a user certificate, 10 years for the Hubject CA) and alert before it expires.
- source: OICP23_Integration_Guide@68e8710:04_Definitions/OICP-status-code.md:7; 01_Overview/02-Getting Started/05-Certificate-Management.md:10-12; oicp@119c5d5:…/01_EMP_Communication_Paradigms.asciidoc:66
- confidence: fact (017 causes, validity); inference (no-retry class, alert lead time)
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-errors.feature

### RH-HUBJECT-ERR-004
WHEN authorize-remote/start returns Result=false THE eMSP SHALL treat the start as failed, SHALL map the StatusCode to a customer message (at least 210, 300, 501, 510, 601, 602, 603, 604, 700), AND SHALL NOT send a SessionID in the initial request.
- source: oicp@119c5d5:…/02_EMP_Services_and_Operations.asciidoc:194-207, 224; 03_EMP_Data_Types.asciidoc:612-623
- confidence: fact
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-errors.feature

### RH-HUBJECT-ERR-005
WHEN the CPO does not answer a remote start or remote stop THE HBS closes the connection with a TimeOut error, AND THE eMSP SHALL keep its client timeout above the CPO window (at least 65 s) and SHALL treat the session state as unknown until a notification, status or CDR resolves it.
- source: OICP23_Integration_Guide@68e8710:03_Services/Services Implementation for CPOs/09-eRoamingAuthorizeRemoteStart.md:13-15; …/10-eRoamingAuthorizeRemoteStop.md:13-15; support 4403421095953 (40 s, conflict)
- confidence: fact (window, TimeOut close); inference (unknown-state handling)
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-errors.feature

### RH-HUBJECT-ERR-006
WHEN the HBS posts a charge-detail-record THE eMSP SHALL answer even if it later fails to process the record, SHALL persist it idempotently by (hub, SessionID), AND IF the eMSP was unreachable THEN it SHALL recover the missed CDRs with GetChargeDetailRecords because the HBS does not resend them.
- source: oicp@119c5d5:…/02_EMP_Services_and_Operations.asciidoc:277-283, 325-347; support 4403421095953 ("CDR will not be resent")
- confidence: fact (one CDR per SessionID, positive result to CPO when we are down, no resend); inference (answer-first)
- priority: pilot
- contract: ../../_sources/hubject-oicp-2.3-emp.openapi.yaml
- verify: acceptance/oicp-errors.feature

### RH-HUBJECT-ERR-007
WHEN the HBS forwards an Error charging notification THE eMSP SHALL read `ErrorType` (`ConnectorError` or `CriticalError`) and show the driver the matching action, AND SHALL close the session on an End notification even when no CDR follows.
- source: oicp-emp-2.3-api-doc@9a773b3:src/schemas/eRoamingChargingNotificationError.yaml; OICP23_Integration_Guide@68e8710:03_Services/Services Implementation for CPOs/06-eRoamingChargingNotifications-End.md:88-92
- confidence: fact
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-errors.feature

### RH-HUBJECT-ERR-008
WHEN the connector pulls EVSE data THE connector SHALL always send `size`, SHALL NOT combine `LastCall` with `SearchCenter`, SHALL tolerate null values for fields that OICP 2.3 requires but older-version CPOs leave empty, AND SHALL hide EVSEs whose `IsHubjectCompatible` is false.
- source: oicp-emp-2.3-api-doc@9a773b3:src/resources/eRoamingData/eRoamingPullEvseData_V2.3.yaml:15-29; oicp@119c5d5:OICP-2.3/Realease_Notes.asciidoc:159-161; …/02_EMP_Services_and_Operations.asciidoc:198-199
- confidence: fact
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-errors.feature

### RH-HUBJECT-ERR-009
WHEN an OPCP webhook arrives THE eMSP SHALL answer with a 5xx status only for transient failures (the webhook service retries 3 times at 1-hour intervals on 5xx, then drops the event), SHALL reject an invalid signature with 400, AND SHALL process events idempotently by `eventId`.
- source: opcp@de066c8:OPCP-1.0.0/docs/components/06_webhook-service.md:48; reference/webhook.payload.v1.json (responses 200, 400)
- confidence: fact (retry rule, documented codes); conflict (401/403 in sample code)
- priority: pilot
- contract: ../../profiles/hubject-opcp-events.asyncapi.yaml
- verify: acceptance/opcp-errors.feature

### RH-HUBJECT-ERR-010
WHEN an OPCP call returns a non-2xx status THE connector SHALL log `traceId` and `errorMessages` from the body, SHALL NOT retry 400, 401 or 403 without changing the request, credentials or configuration, AND SHALL obtain a new access token when the current one is no longer valid.
- source: opcp@de066c8:OPCP-1.0.0/reference/cps.v1.json, ccp.v1.json, pcp.v1.json (error examples); reference/accessToken.v1.json (`expires_in`); docs/04_authentication.md:18-21
- confidence: fact (error shape, codes); inference (retry classes)
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/opcp-errors.feature

### RH-HUBJECT-ERR-011
WHEN `getOEMProvCert` or `generateSignedContractData` reports that the provisioning certificate for a PCID is not found or not available THE eMSP SHALL NOT create a contract for it AND SHALL tell the customer the vehicle is not yet available for Plug&Charge.
- source: opcp@de066c8:OPCP-1.0.0/reference/pcp.v1.json (404 "…not found"); reference/cps.v1.json (400 "…is not available")
- confidence: fact (messages); project requirement (customer message)
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/opcp-errors.feature

### RH-HUBJECT-ERR-012
WHEN the webhook service reports `mo.prov.cert.deleted`, `mo.prov.cert.updated` or `mo.prov.cert.factory.reset` THE eMSP SHALL treat all contracts of that PCID as removed from the CCP (Hubject deletes them), SHALL NOT create new contracts for a factory-reset PCID, AND SHALL ask the customer whether to re-create after an update.
- source: opcp@de066c8:OPCP-1.0.0/docs/components/06_webhook-service.md:22-25; docs/components/02_provisioning-certificate-pool.md:77, 90
- confidence: fact
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/opcp-errors.feature

### RH-HUBJECT-ERR-013
THE app SHALL offer remote start only for EVSEs of operators with which the eMSP holds an active subscription AND whose `IsHubjectCompatible` is true, because the HBS answers 210, 603 or 604 otherwise.
- source: oicp@119c5d5:…/02_EMP_Services_and_Operations.asciidoc:194-199; OICP23_Integration_Guide@68e8710:03_Services/Services Implementation for EMPs/03-PullEvseStatus by OperatorID.md:7-9; …/04-RoamingAuthorizeRemoteStart.md:26-28
- confidence: fact (HBS behaviour); project requirement (catalogue filter)
- priority: pilot
- contract: ../../profiles/hubject-oicp-2.3-emp.profile.yaml
- verify: acceptance/oicp-errors.feature
