Feature: Remote stop and charging notifications via Hubject
  @RH-HUBJECT-CMD-002 @mock
  Scenario: Remote stop uses our ProviderID in the path
    Given a running session with Hubject SessionID "S-3" at EVSE "TR*ZES*E1"
    When the driver stops the session in the app
    Then the connector posts to "/charging/v21/providers/TR*XYZ/authorize-remote/stop"
    And the body has SessionID "S-3", ProviderID "TR*XYZ" and EvseID "TR*ZES*E1"

  @RH-HUBJECT-CDR-003 @mock
  Scenario: End notification closes a session without a CDR
    Given session "S-4" is active
    When the HBS posts a charging notification of Type "End" for "S-4"
    Then the response has Result true and StatusCode "000"
    And session "S-4" is closed

  @RH-HUBJECT-CDR-003 @mock
  Scenario: Progress notification updates energy
    When the HBS posts a "Progress" notification with ConsumedEnergyProgress 9 for "S-4"
    Then the app session shows 9 kWh
