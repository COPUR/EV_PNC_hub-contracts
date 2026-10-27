Feature: Remote start and charge detail records via Hubject
  @RH-HUBJECT-CMD-001 @mock
  Scenario: Remote start accepted
    Given the app requests a session at EVSE "DE*ABC*E1" for contract "DE*XYZ*C00001*1"
    When the connector posts authorize-remote/start with a new SessionID
    And the hub mock answers Result true
    Then the session is marked "start requested"

  @RH-HUBJECT-CMD-001 @mock
  Scenario: Remote start rejected
    When the hub mock answers Result false with a StatusCode
    Then the app receives a failed start with the mapped reason

  @RH-HUBJECT-CMD-002 @pending-confirmation
  Scenario: Remote stop uses the documented path
    Given a running session "S-2"
    When the connector stops it remotely
    Then the request goes to ".../providers/{externalID}/authorize-remote/stop"

  @RH-HUBJECT-CDR-001 @mock
  Scenario: CDR is stored once
    When the HBS posts the same charge-detail-record twice for SessionID "S-2"
    Then both responses have Result true
    And exactly one canonical CDR exists for "S-2"

  @RH-HUBJECT-CDR-002 @mock
  Scenario: Price is computed by the eMSP
    Given the tariff for contract "DE*XYZ*C00001*1" at "DE*ABC*E1" is 0.50 EUR/kWh
    When the HBS posts a CDR with ConsumedEnergy 20.0
    Then the canonical CDR total_cost equals 10.00 EUR

  @RH-HUBJECT-CMD-003 @mock
  Scenario: Remote start omits SessionID and stores the returned one
    When the driver starts a session from the app
    Then the authorize-remote/start body has no SessionID
    And the SessionID from the response is stored
    And the client timeout is at least 45 seconds
