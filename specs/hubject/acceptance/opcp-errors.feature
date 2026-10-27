Feature: OPCP failure handling and happy paths (mock)
  Background:
    Given the connector has OAuth credentials for EMAID prefix "TRXYZ"

  @happy @RH-HUBJECT-PNC-001 @mock
  Scenario: Contract created and delivered
    Given the PCP holds PCID "WVWZZZ1KZ6W123456"
    When the customer registers that PCID
    Then the connector calls getOEMProvCert and creates the contract
    And a "mo.contract.delivered.to.oem" webhook is stored

  @error @RH-HUBJECT-ERR-010 @mock
  Scenario Outline: OPCP error responses are logged with traceId
    Given the CPS mock answers <status> with errorMessages and traceId
    When the connector creates contract data
    Then the log contains the traceId and the first error message
    And <retry rule>
    Examples:
      | status | retry rule                          |
      | 400    | no retry is scheduled               |
      | 401    | a new access token is requested     |
      | 403    | an alert says "check EMAID prefix"  |
      | 503    | a retry with backoff is scheduled   |

  @error @RH-HUBJECT-ERR-011 @mock
  Scenario: PCID not in the PCP
    Given the PCP mock answers 404 "The OEM provisioning certificate with given PCID is not found."
    When the customer registers PCID "XXXZZZ1KZ6W123456"
    Then no contract is created
    And the customer is told the vehicle is not yet available for Plug&Charge

  @error @RH-HUBJECT-ERR-010 @mock
  Scenario: EMAID already used by another PCID
    Given the CPS mock answers 400 "Invalid Tupple - EMAID is already used by other PCID."
    When the connector creates contract data
    Then a new EMAID instance is generated and the call is repeated once

  @error @RH-HUBJECT-ERR-010 @mock
  Scenario: Contract end date in the past
    Given the CPS mock answers 400 "The given contractEnds date is in the past."
    Then the registration stops with a validation error

  @error @RH-HUBJECT-ERR-009 @mock
  Scenario: Invalid webhook signature
    When a webhook arrives with a wrong signature
    Then the response status is 400
    And the event is not processed

  @error @RH-HUBJECT-ERR-009 @mock
  Scenario: Transient failure returns 5xx, duplicate is ignored
    Given the database is unavailable when a valid webhook arrives
    Then the response status is 503
    When the same event arrives again with the same eventId after recovery
    Then it is processed once

  @error @RH-HUBJECT-ERR-012 @mock
  Scenario Outline: Provisioning certificate lifecycle events
    Given PCID "ABC12345678901234" has contract EMAID "TRXYZC00000011"
    When a valid "<event>" webhook arrives for that PCID
    Then the contract is marked removed
    And <consequence>
    Examples:
      | event                          | consequence                                      |
      | mo.prov.cert.deleted           | the customer is told Plug&Charge is disabled     |
      | mo.prov.cert.updated           | the customer is asked whether to re-create       |
      | mo.prov.cert.factory.reset     | no new contract can be created for that PCID     |

  @error @RH-HUBJECT-ERR-012 @mock
  Scenario: Root certificate revoked
    When a valid "root.cert.revoked" webhook arrives
    Then operations are alerted
    And no contracts are deleted by the connector
