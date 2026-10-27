Feature: Plug&Charge contract provisioning through OPCP
  Background:
    Given the connector has OAuth2 credentials for EMAID prefix "DEXYZ"

  @RH-HUBJECT-PNC-001 @mock
  Scenario: Vehicle certificate is validated before a contract is issued
    Given the PCP holds a provisioning certificate for PCID "WVWZZZ1KZ6W123456"
    When the customer registers PCID "WVWZZZ1KZ6W123456"
    Then the connector calls getOEMProvCert and getAllRootCerts
    And the chain is validated against the OEM root
    And an invalid chain stops the registration with a reason

  @RH-HUBJECT-PNC-002 @mock
  Scenario: Own-PKI contract is signed and published
    When the connector creates contract data for EMAID "DE*XYZ*C00001*1" and PCID "WVWZZZ1KZ6W123456"
    Then it calls createAndForwardSignedContractData
    And lookupContract for the EMAID returns the contract

  @RH-HUBJECT-PNC-004 @mock
  Scenario: Second contract for the same vehicle
    Given the CCP holds EMAID "DE*XYZ*C00001*1" for the PCID
    When the connector publishes EMAID "DE*XYZ*C00002*1" for the same PCID
    And marks it default
    Then getContracts for the PCID lists both with the second flagged default

  @RH-HUBJECT-PNC-004 @mock
  Scenario: Renewal overwrites the same EMAID
    When the connector publishes a new certificate for EMAID "DE*XYZ*C00001*1"
    Then lookupContract returns one entry with the new validity dates

  @RH-HUBJECT-PNC-005 @mock
  Scenario: Foreign EMAID prefix is refused
    When the connector calls lookupContract for EMAID "DE*OTH*C00001*1"
    Then the call is refused by the ecosystem
    And the failure is classified "configuration"

  @RH-HUBJECT-PNC-009 @mock
  Scenario Outline: OPCP environment comes from configuration
    Given the stage "<stage>" and region "<region>"
    Then the client base URL is built from stage, region and domain
    Examples:
      | stage            | region |
      | plugncharge-test | eu     |
      | plugncharge-qa   | eu     |
      | plugncharge      | eu     |

  @RH-HUBJECT-PNC-010 @mock
  Scenario: EMAIDs are normalised
    Given the EMAID "tr-xyz-c0000001-1"
    When the platform sends it to OPCP
    Then the value is "TRXYZC00000011"
