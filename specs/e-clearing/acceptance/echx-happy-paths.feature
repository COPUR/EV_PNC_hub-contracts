Feature: ECHX happy paths for the eMSP
  Background:
    Given a mock ECHX hub speaking OCPI 2.2.1 per e-clearing-echx-ocpi-2.2.1.profile.yaml

  @happy @RH-ECLEARING-VER-001 @mock
  Scenario: version is selected
    When the platform negotiates versions
    Then it selects "2.2.1"

  @happy @RH-ECLEARING-REG-001 @RH-ECLEARING-OPS-001 @mock
  Scenario: connection change is verified after propagation
    When an operator changes a roaming connection in the ECHX frontend
    Then the runbook waits up to 2 minutes before verifying

  @happy @RH-ECLEARING-REG-002 @mock
  Scenario: Charge Club acceptance
    Given both parties are on the productive system with complete contact details
    When the eMSP accepts a CPO offer
    Then the connection is recorded as starting the next day unless the offer sets another date

  @happy @RH-ECLEARING-LOC-001 @mock
  Scenario: paginated location pull
    Given ECHX returns pages with a Link header
    When the platform pulls locations with cpo filter
    Then it follows Link until it is empty

  @happy @RH-ECLEARING-CMD-001 @mock
  Scenario: command accepted and session started
    Given the platform sends START_SESSION and receives ACCEPTED with timeout 60
    When ECHX posts CommandResult ACCEPTED to the response_url
    And a session arrives with authorization_reference "DIRECT-123"
    Then the platform stores the reference unchanged

  @happy @RH-ECLEARING-CDR-001 @mock
  Scenario: CDR reconciled in time
    Given a CDR is received 3 days after session end
    When the platform reconciles it
    Then no retention alert is raised
