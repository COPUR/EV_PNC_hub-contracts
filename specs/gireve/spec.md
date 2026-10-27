# Spec: GIREVE connector (eMSP role)

**Status:** draft from public sources, 2026-10-24 · **Baseline:** OCPI 2.3.0 eMSP, speaking 2.2.1 to GIREVE · **Contracts:** `../../profiles/`
**Sources:** GIREVE OCPI 2.2.1 Implementation Guide v1.5, OCPI 2.2.1 Implementation Guide v1.6 (2026-09-20), PNCP Implementation Guide (GitHub copy, read in full; mutual TLS since 2026-09-22).

## Scope

In: OCPI 2.2.1 eMSP via the GIREVE IOP, PNCP eMSP role (contract certificates), compatibility layer from the 2.3.0 baseline.
Out: CPO role, OCPI 2.1.1, eMIP (specification not retrieved), Eichrecht signed-data activation, Advenir.

## Requirements

Build-ready only: fact-based, pilot priority. Unknowns, inferences and later items are in `../../analysis/backlog.md`.

### RH-GIREVE-REG-001
WHEN onboarding THE eMSP platform SHALL let the IOP register FromIOP (the IOP calls our versions and credentials endpoints with the temporary token), present a GIREVE-issued client certificate on calls to the IOP, provide GIREVE the certificate the IOP uses to call us, call from allow-listed IPs, and use Base64-encoded authorization tokens.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §1.3, §2.1.2, §3.4, §4.2
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-registration.feature

### RH-GIREVE-REG-002
WHEN credentials or endpoints change THE eMSP platform SHALL unregister and register again, because credentials update is not implemented.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §3.5.1
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-registration.feature

### RH-GIREVE-REG-003
THE eMSP platform SHALL use the hub party (FR*107 pre-production, FR*007 production) in routing headers and SHALL treat every operator hosted on the platform as covered by one handshake.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §2.1.3, §2.1.6
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-registration.feature

### RH-GIREVE-REG-004
THE eMSP platform SHALL send OCPI-to and OCPI-from headers on every request except credentials and versions, and SHALL send and echo X-Request-ID and X-Correlation-ID.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §2.1.4, §2.1.5
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-registration.feature

### RH-GIREVE-VER-001
THE eMSP platform SHALL speak OCPI 2.2.1 to GIREVE; 2.3.0 is not offered in the published guides.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf; GIREVE guide list
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-registration.feature

### RH-GIREVE-TOK-001
WHEN the IOP posts tokens/{uid}/authorize for a token THE eMSP platform SHALL answer in real time with AuthorizationInfo for the Location referenced.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §3.6, §4.4
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-token-session-cdr.feature

### RH-GIREVE-TOK-002
THE eMSP platform SHALL NOT push Plug&Charge tokens (canonical type EMAID, sent as OTHER in 2.2.1); for RFID and app tokens it SHALL push the full list when a connected CPO is on OCPI 2.1.1.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.4.1, §4.4.4; COPUR/ocpi (OCPI 2.3.0) mod_tokens
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-token-session-cdr.feature

### RH-GIREVE-TOK-003
THE eMSP platform SHALL normalise RFID UIDs to uppercase hexadecimal of 4 or 7 bytes, zero-padded, before pushing.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §2.3.3
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-token-session-cdr.feature

### RH-GIREVE-TOK-004
THE eMSP platform SHALL NOT rely on PATCH token to the IOP or on pulling tokens from the IOP.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.4
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-token-session-cdr.feature

### RH-GIREVE-CMD-001
WHEN the app starts a session at a GIREVE-roamed EVSE THE eMSP platform SHALL send START_SESSION with evse_uid set and the routing headers for the target CPO.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.5
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-token-session-cdr.feature

### RH-GIREVE-CMD-002
THE eMSP platform SHALL NOT offer reservation, cancel-reservation or unlock-connector at GIREVE-roamed EVSEs.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.5
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml

### RH-GIREVE-SESSION-001
WHEN the IOP delivers sessions and CDRs THE eMSP platform SHALL accept store-and-forward replays idempotently and SHALL NOT assume the session id equals the CPO's id.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.6, §2.1.7
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-token-session-cdr.feature

### RH-GIREVE-CDR-001
WHEN a CDR carries a remark prefix THE eMSP platform SHALL interpret [*] as priced by GIREVE and [?] as price not significant, and SHALL still validate totals itself.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.7
- confidence: fact (prefix), inference (validation)
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-token-session-cdr.feature

### RH-GIREVE-TARIFF-002
WHEN pulling tariffs THE eMSP platform SHALL page at most 100 per page and keep date ranges under one month, and SHALL support the SESSION_TIME dimension.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.8
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-tariffs-locations.feature

### RH-GIREVE-LOC-001
THE eMSP platform SHALL accept extra GIREVE fields (gireve_id), non-compliant evse_id values, and static data that updates with hours of delay.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.3
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-tariffs-locations.feature

### RH-GIREVE-LOC-002
THE platform SHALL read ISO_15118_2_PLUG_AND_CHARGE and ISO_15118_20_PLUG_AND_CHARGE from connector capabilities (and EVSE capabilities if present) to mark Plug&Charge-capable EVSEs.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §3.5.5, §4.3.7, §4.3.10
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-tariffs-locations.feature

### RH-GIREVE-PNC-002
THE eMSP SHALL call PNCP with mutual TLS (GIREVE-provisioned client certificate) and an OAuth2 bearer token from its client_id and client_secret, reuse the token until expiry, send minified JSON, and identify itself with PNCP-from-country-code and PNCP-from-party-id.
- source: https://github.com/Gireve/pncp-implementation-guide §2.5, §2.7.1, §2.7.3, §2.8.1, §2.8.2
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-pncp-1.2.0.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-003
THE eMSP SHALL use ECDSA secp256r1 keys, PKCS#10 PEM CSRs, and renew with a new key pair (key reuse is rejected).
- source: https://www.gireve.com/wp-content/uploads/2026/05/Gireve_Info_Cnx_PNCP-Implementation-Guide_1.2.0_en.pdf §3.3
- confidence: fact
- priority: pilot
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-005
WHEN a Plug&Charge session authorizes THE eMSP platform SHALL accept the OCPI authorize call with the eMAID in auth_id (type OTHER in 2.2.1) and SHALL map it to the contract.
- source: https://www.gireve.com/wp-content/uploads/2026/05/Gireve_Info_Cnx_PNCP-Implementation-Guide_1.2.0_en.pdf §3.6.3.2
- confidence: fact
- priority: pilot
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-006
THE eMSP SHALL subscribe to root.certificate.* and emsp.contract.certificate.expiring.soon (50 days) webhooks, verify the HMAC-SHA256 payload-signature, and allow-list GIREVE's fixed outgoing IP.
- source: https://www.gireve.com/wp-content/uploads/2026/05/Gireve_Info_Cnx_PNCP-Implementation-Guide_1.2.0_en.pdf §3.5
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-pncp-events.asyncapi.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-SEC-001
THE platform SHALL NOT send or log client secrets, tokens or private keys; the encrypted contract private key leaves our PKI only inside signed contract data.
- source: engineering rule
- confidence: project requirement (security baseline)
- priority: pilot
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-001
WHEN a customer activates Plug&Charge for a vehicle THE eMSP SHALL call "Create CC, build & sign the CCB and store in CCP" with the customer's eMAID and the vehicle PCID (and its assigned certificate profile), so that GIREVE issues the contract certificate, builds and signs the bundle and stores the SCCB in the CCP.
- source: https://github.com/Gireve/pncp-implementation-guide §3.7.1, §3.7.1.1.1, §3.7.1.3
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-pncp-1.2.0.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-004
WHEN a CPO or OEM requests installation THE eMSP SHALL NOT assume its contract wins: GIREVE returns every eligible SCCB with owner_operator and the CPO installs one, possibly preferring eMSPs it has a roaming contract with.
- source: https://github.com/Gireve/pncp-implementation-guide §3.6.3
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-VER-002
THE platform SHALL convert between canonical OCPI 2.3.0 and OCPI 2.2.1 using the conversion table, sending no 2.3.0-only modules, fields or enum values to GIREVE.
- source: OCPI 2.2.1 spec vs COPUR/ocpi (OCPI 2.3.0) table diff; COPUR/ocpi (OCPI 2.3.0) changelog; https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §2.1.10, §4.4.4, §4.5
- confidence: fact
- priority: pilot
- contract: ../../profiles/ocpi-2.3.0-to-2.2.1.conversion.yaml
- verify: acceptance/ocpi-registration.feature

### RH-GIREVE-CERT-001
BEFORE production THE eMSP platform SHALL pass GIREVE's OCPI 2.2.1 eMSP certification tests and PNCP certification, because GIREVE may suspend an uncertified platform.
- source: https://www.gireve.com/download/ (OCPI-2.2.1-CertificationTests-eMSP V1.1); GIREVE GTC 1.0.0 GTC; https://github.com/Gireve/pncp-implementation-guide §2.8.1; gireve.com/plug-and-charge-services
- confidence: fact (obligation); unknown (test content)
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: runbook check (certification tests, T-GIREVE-24)

### RH-GIREVE-TARIFF-001
THE eMSP platform SHALL expect only REGULAR ("B2B Regular") tariffs from GIREVE and SHALL NOT expect AD_HOC_PAYMENT or PROFILE_* tariffs.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §2.3.2, §3.10, §4.8.3
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-tariffs-locations.feature

### RH-GIREVE-REG-005
WHEN the IOP sends DELETE credentials THE eMSP platform SHALL drop the IOP credentials and accept a new Register FromIOP.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §3.4, §4.2; https://github.com/Gireve/ocpi-2.1.1-implementation-guide emsp_registration.md
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-registration.feature

### RH-GIREVE-SEC-002
THE eMSP platform SHALL accept inbound IOP calls only over HTTPS with the client certificate provisioned for the IOP and from GIREVE's IPs.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §2.1.2
- confidence: fact (cert both ways); inference (our IP check)
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-registration.feature

### RH-GIREVE-TOK-005
WHEN sending or receiving a Plug&Charge token over OCPI 2.2.1 THE platform SHALL use type OTHER with uid and contract_id equal to the eMAID of the contract certificate.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.4.4
- confidence: fact
- priority: pilot
- contract: ../../profiles/ocpi-2.3.0-to-2.2.1.conversion.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-VER-003
THE canonical model SHALL hold Location.address up to 255 characters, Location.state up to 45 and SignedValue.plain_data up to 5000, as allowed by OCPI 2.2.1.
- source: OCPI 2.2.1 spec vs COPUR/ocpi (OCPI 2.3.0) mod_locations, mod_cdrs
- confidence: fact
- priority: pilot
- contract: ../../profiles/ocpi-2.3.0-to-2.2.1.conversion.yaml
- verify: acceptance/ocpi-tariffs-locations.feature

### RH-GIREVE-TARIFF-003
WHEN a tariff carries target_operator_country_code and target_operator_party_id equal to our party THE platform SHALL use it instead of the untargeted tariff with the same id.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §3.10.4, §4.8.5
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-tariffs-locations.feature

### RH-GIREVE-SESSION-002
THE eMSP platform SHALL NOT pull sessions or CDRs from the IOP and SHALL tolerate missing intermediate session updates (only ACTIVE and COMPLETED are retried by CPOs; updates under 2 minutes apart may be dropped).
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §3.8.4, §3.8.5, §4.6.4, §4.7.5
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/ocpi-token-session-cdr.feature

### RH-GIREVE-PNC-008
THE eMSP SHALL use pp-trust-secure-api.gireve.com (pre-production) and trust-secure-api.gireve.com (production) with TLS 1.3, trust GTS Root R1, and keep the client TLS private key on the component that terminates TLS.
- source: https://github.com/Gireve/pncp-implementation-guide §2.3, §2.5, §2.7.1
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-pncp-1.2.0.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-009
BEFORE requesting a contract certificate THE eMSP SHALL generate eMAIDs in ISO 15118-2 Annex H.1 format with our registered country code and provider ID.
- source: https://www.gireve.com/wp-content/uploads/2026/05/Gireve_Info_Cnx_PNCP-Implementation-Guide_1.2.0_en.pdf §3.7.1.1.2
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-010
WHEN a customer enters a PCID THE eMSP MAY call "Check a PCID in PCP" before Build Sign Store and SHALL tell the customer when the PCID is unknown.
- source: https://github.com/Gireve/pncp-implementation-guide §3.7.8
- confidence: fact (service); project rule (message)
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-011
WHEN the eMSP receives emsp.provisionning.certificate.removed, .revoked or .updated for a contract not yet installed THE eMSP SHALL regenerate the SCCB with the new provisioning certificate.
- source: https://github.com/Gireve/pncp-implementation-guide §3.5.3, §3.7.10
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-pncp-events.asyncapi.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-012
WHEN a customer's Plug&Charge contract ends THE eMSP SHALL call "Deactivate an eMAId" (or "Revoke a CC" for one certificate) for certificates created through Build Sign Store.
- source: https://github.com/Gireve/pncp-implementation-guide §3.7.5.1
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-013
WHEN emsp.contract.certificate.expiring.soon arrives (50 days before expiry of a 2-year certificate) THE eMSP SHALL renew by calling Build Sign Store again with the same eMAID.
- source: https://github.com/Gireve/pncp-implementation-guide §3.7.2, §3.7.4
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-014
THE eMSP SHALL offer GIREVE-issued Plug&Charge only for ISO 15118-2 (urn:iso:15118:2:2013:MsgDef); ISO 15118-20 is not accepted yet.
- source: https://github.com/Gireve/pncp-implementation-guide §3.6.3
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-PNC-015
THE eMSP SHALL use only certificate profile IDs GIREVE assigned to it, held in configuration.
- source: https://github.com/Gireve/pncp-implementation-guide §3.3.1
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-pncp-1.2.0.profile.yaml
- verify: acceptance/pncp-contract-certificate.feature

### RH-GIREVE-ERR-001
WHEN the IOP posts tokens/{uid}/authorize for a uid the eMSP does not know THE eMSP SHALL respond with status_code 2004 and no data field.
- source: https://github.com/ocpi/ocpi/blob/release-2.2.1-bugfixes/mod_tokens.asciidoc (POST authorize); https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.4
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-002
WHEN the eMSP knows the token but refuses it THE eMSP SHALL answer AuthorizationInfo with allowed BLOCKED, EXPIRED, NO_CREDIT or NOT_ALLOWED.
- source: OCPI 2.2.1 mod_tokens AllowedType
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-003
WHEN no CommandResult arrives within CommandResponse.timeout THE eMSP SHALL treat the command as possibly never delivered and tell the driver.
- source: OCPI 2.2.1 mod_commands CommandResponse.timeout
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-004
WHEN the IOP answers 4001, 4002 or 4003 THE eMSP SHALL map them to unknown receiver, forwarded-request timeout and receiver not connected.
- source: OCPI 2.2.1 status_codes.asciidoc
- confidence: fact (meaning); unknown (when GIREVE uses them)
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-005
WHEN the IOP calls our credentials POST and one of our GETs to the IOP fails THE eMSP SHALL answer 3001; with no common version 3002; with missing endpoints 3003.
- source: OCPI 2.2.1 status_codes.asciidoc
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-006
WHEN pulling any module from the IOP THE eMSP SHALL follow the Link header until the last page.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §2.1.8
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-007
WHEN a PNCP access token is missing, invalid or expired THE eMSP SHALL obtain a new token before resending, and SHALL NOT request a new token while one is valid.
- source: https://github.com/Gireve/pncp-implementation-guide §2.8.1
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-008
WHEN a CDR or session arrives again with the same identifiers THE eMSP SHALL keep one record.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §3.8.5, §3.9.4
- confidence: fact (replays occur)
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-009
WHEN a CDR remark starts with [?] THE eMSP SHALL price the CDR from the applicable B2B Regular tariff itself.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §2.3.2, §4.7.3
- confidence: fact (meaning); project rule (self-pricing)
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature

### RH-GIREVE-ERR-010
WHEN the driver asks for reservation or unlock at a GIREVE-roamed EVSE THE app SHALL NOT offer it.
- source: https://www.gireve.com/wp-content/uploads/2026/09/Gireve_Tech_OCPI-V2.2.1_ImplementationGuide_V1.6-_en.pdf §4.5.4–4.5.6
- confidence: fact
- priority: pilot
- contract: ../../profiles/gireve-ocpi-2.2.1.profile.yaml
- verify: acceptance/flows.feature
