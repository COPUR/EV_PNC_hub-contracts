Feature: ECHX error flows for the eMSP
  Background:
    Given a mock ECHX hub speaking OCPI 2.2.1 per e-clearing-echx-ocpi-2.2.1.profile.yaml

  @error @RH-ECLEARING-ERR-001 @mock
  Scenario: unknown-token
    When the hub forwards an authorize for an unknown token
    Then the platform answers status_code 2004 with no data field

  @error @RH-ECLEARING-ERR-002 @mock
  Scenario: authorize-no-location
    When the hub forwards an authorize without LocationReferences
    Then the platform answers status_code 2002

  @error @RH-ECLEARING-ERR-003 @mock
  Scenario Outline: command-rejected
    Given the platform sent a START_SESSION
    When the CommandResponse is "<response>"
    Then the command is marked not started
    And no automatic retry is sent
    Examples:
      | response        |
      | NOT_SUPPORTED   |
      | REJECTED        |
      | UNKNOWN_SESSION |

  @error @RH-ECLEARING-ERR-003 @mock
  Scenario Outline: command-result-failure
    Given a START_SESSION was accepted
    When the CommandResult is "<result>"
    Then the command is marked not started
    Examples:
      | result           |
      | EVSE_OCCUPIED    |
      | EVSE_INOPERATIVE |
      | FAILED           |
      | REJECTED         |
      | TIMEOUT          |

  @error @RH-ECLEARING-ERR-004 @mock
  Scenario: command-timeout
    Given a START_SESSION was accepted with timeout 60
    When no CommandResult arrives within 60 seconds
    Then the platform checks the session list
    And reports the outcome as unconfirmed if no session exists

  @error @RH-ECLEARING-ERR-005 @mock
  Scenario: outage-resync
    Given a PATCH to the hub times out
    Then the message is not queued for replay
    When the hub is reachable again
    Then the platform pulls locations and CDRs for the outage window

  @error @RH-ECLEARING-ERR-006 @mock
  Scenario: dedupe
    Given a token list with a repeated uid
    When the platform sends the list
    Then each uid appears once

  @error @RH-ECLEARING-ERR-007 @RH-ECLEARING-ID-001 @mock
  Scenario: exact-case
    Given stored token uid "ab12cd"
    When the platform references it to ECHX
    Then the uid is sent as "ab12cd"

  @error @RH-ECLEARING-LOC-003 @mock
  Scenario: terminated-location
    Given ECHX delivers a location marked terminated 5 days ago
    Then the location is hidden from search and planning

  @error @RH-ECLEARING-LOC-002 @mock
  Scenario: placeholders-and-utc
    Given a location with "-" in a mandatory field and no time_zone
    Then it is stored as not provided and flagged "defaulted UTC"

  @error @RH-ECLEARING-CDR-002 @mock
  Scenario: cdr-unknown-location
    Given a CDR whose location is an EVSE ID unknown to the platform
    Then the CDR is accepted and linked by EVSE ID

  @error @RH-ECLEARING-CDR-001 @mock
  Scenario: cdr-near-retention-limit
    Given a CDR has been expected for 26 days and is not reconciled
    Then an alert is raised

  @error @RH-ECLEARING-CMD-002 @mock
  Scenario: no-charging-profile
    Given the planner wants a charging profile on an ECHX session
    Then no ChargingProfiles request is sent

  @error @RH-ECLEARING-ERR-008 @mock
  Scenario: charge-club-cancel
    Given a Charge Club cancellation requested on 2026-11-05
    Then the termination date is recorded as 2026-12-05
    And the CPO's locations are hidden once ECHX stops delivering them
