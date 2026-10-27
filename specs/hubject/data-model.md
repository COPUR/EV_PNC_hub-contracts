# Data model: identifiers and entities (Hubject)

| Concept | Hubject form | Canonical (OCPI 2.3.0) form | Notes | Source |
|---|---|---|---|---|
| eMSP | ProviderID, country code plus provider ID (for example `DE*XYZ`) | `country_code` + `party_id`, role EMSP | Bound to the client certificate | OICP 2.2 §2.7, §5.3.3 |
| CPO | OperatorID | `country_code` + `party_id`, role CPO | Needed to route and to apply operator allow and block lists | OICP 2.2 §5.3.4 |
| Contract | EvcoID `DE*8EO*Aet5e4*3` style | `contract_id`; token `type=EMAID` for Plug&Charge | EvcoID equals EMAID | OICP 2.3 schemas, `mod_tokens` |
| Vehicle | PCID (ISO 15118 provisioning certificate ID) | none; keep in the plugcharge domain | First three characters are the WMI | OPCP 05_handling-of-ids.md |
| EVSE | EvseID | `evse_id` | Operator-based ID format | OICP schemas |
| Session | SessionID (HBS generated), CPOPartnerSessionID, EMPPartnerSessionID | session `id` plus `hub_session_ref` | Echo on every call; EMPPartnerSessionID is ours to use | OICP 2.2 §2.6, schemas |
| CDR | ChargeDetailRecord keyed by SessionID | cdr | No price fields | OICP schema |
| Contract data | signed contract data (EXI/XML string) per EMAID and PCID | none; owned by plugcharge | CCP stores several per PCID | OPCP ccp.v1.json |

Open: EVSE ID matching between OICP and OCPI location data (Q-HUBJECT-07 to raise once EVSE data is pulled).

## Added after the deep run (2026-10-24)

- `Address.Country` in OICP is ISO alpha-3 (`TUR`); IDs use alpha-2 (`TR*XYZ`).
- OICP time zone is optional; derive `Europe/Istanbul` for Turkish EVSEs.
- NGP EVSE group and tariff name map to the CDR `PartnerProductID`.
