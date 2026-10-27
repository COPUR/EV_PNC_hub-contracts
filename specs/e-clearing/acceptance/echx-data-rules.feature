Feature: ECHX OCPI 2.2.1 data rules for the eMSP
  Background:
    Given a mock ECHX hub speaking OCPI 2.2.1 per e-clearing-echx-ocpi-2.2.1.profile.yaml

  @RH-ECLEARING-VER-001 @mock
  Scenario: version
    When the platform negotiates versions with ECHX
    Then it selects "2.2.1"

  @RH-ECLEARING-ID-001 @mock
  Scenario: case-sensitive-ids
    Given ECHX pushes tokens with uids "ab12" and "AB12"
    Then the platform stores two distinct tokens

  @RH-ECLEARING-ID-002 @mock
  Scenario: id-prefix
    When the platform creates a token for ECHX
    Then the token uid starts with our country code and party id

  @RH-ECLEARING-LOC-001 @mock
  Scenario: pagination
    Given ECHX returns X-Total-Count 10 and a Link header for a next page
    When the platform pulls locations
    Then it follows Link until no Link header is returned
    And it ignores X-Total-Count

  @RH-ECLEARING-LOC-002 @mock
  Scenario: placeholders
    Given a location with name "-", no time_zone and an EVSE without evse_id
    When the platform ingests it
    Then the location is stored with name unknown and time zone flagged "defaulted UTC"
    And no "-" is shown in the driver app

  @RH-ECLEARING-LOC-003 @mock
  Scenario: terminated-locations
    Given ECHX delivers a location marked terminated
    Then the location is hidden from search and planning

  @RH-ECLEARING-TOK-001 @mock
  Scenario: full-patch
    When the platform patches a token's energy_contract
    Then the PATCH body contains the complete energy_contract object

  @RH-ECLEARING-CDR-001 @mock
  Scenario: cdr-retention
    Given an ECHX CDR received 26 days ago is not reconciled
    Then an alert is raised

  @RH-ECLEARING-CDR-002 @mock
  Scenario: cdr-unknown-location
    Given a CDR whose location id is an EVSE ID unknown to the platform
    Then the CDR is accepted and linked by EVSE ID

  @RH-ECLEARING-CMD-001 @mock
  Scenario: auth-reference
    Given ECHX sends a session with authorization_reference "DIRECT-123"
    Then the platform stores it unchanged and does not parse it

  @RH-ECLEARING-CMD-002 @mock
  Scenario: no-charging-profiles
    Given the planner wants a charging profile for an ECHX session
    Then no ChargingProfiles request is sent to ECHX
