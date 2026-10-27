Feature: Authorize requests from the Hubject HBS
  Background:
    Given the connector exposes the OICP "authorize/start" endpoint
    And the contract store holds an active contract "DE*XYZ*C00001*1" and an RFID token "04A1B2C3D4E5F6"

  @RH-HUBJECT-AUTH-001 @RH-HUBJECT-AUTH-006 @mock
  Scenario: Known RFID token is authorized
    When the HBS posts authorize/start with RFID UID "04A1B2C3D4E5F6" and SessionID "S-1"
    Then the response has AuthorizationStatus "Authorized" and ProviderID "DE*XYZ"
    And SessionID "S-1" is stored against the authorization

  @RH-HUBJECT-AUTH-002 @mock
  Scenario: RFID token of another EMP is not authorized
    When the HBS posts authorize/start with RFID UID "FFFFFFFFFFFFFF"
    Then the response has AuthorizationStatus "NotAuthorized"
    And the response is returned without an error status for the HBS

  @RH-HUBJECT-AUTH-003 @RH-HUBJECT-PNC-007 @mock
  Scenario: Plug&Charge EvcoID is authorized through the policy engine
    Given the policy engine allows operator "DE*ABC" at price below 0.60 EUR/kWh
    When the HBS posts authorize/start with PlugAndChargeIdentification EvcoID "DE*XYZ*C00001*1" and EvseID "DE*ABC*E1"
    Then the response has AuthorizationStatus "Authorized"

  @RH-HUBJECT-AUTH-003 @mock
  Scenario: Policy blocks an operator
    Given the policy engine blocks operator "DE*BAD"
    When the HBS posts authorize/start with PlugAndChargeIdentification EvcoID "DE*XYZ*C00001*1" and EvseID "DE*BAD*E9"
    Then the response has AuthorizationStatus "NotAuthorized"

  @RH-HUBJECT-AUTH-004 @mock
  Scenario: Slow policy decision falls back before 10 s
    Given the policy engine takes longer than the internal budget
    When the HBS posts authorize/start
    Then the response is returned within 10 seconds
    And AuthorizationStatus is "NotAuthorized" with StatusCode "021"
