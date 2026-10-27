Feature: OICP identity and environment handling
  Background:
    Given the connector is configured with ProviderID "DE*XYZ" and a client certificate issued for it

  @RH-HUBJECT-SEC-001 @sandbox
  Scenario: Requests carry the certificate-bound ProviderID
    When the connector calls "authorize-remote/start" on the QA environment
    Then the request is sent over HTTPS with the client certificate
    And the body ProviderID equals "DE*XYZ"

  @RH-HUBJECT-SEC-002 @mock
  Scenario: Mismatched ProviderID is a configuration error
    Given the hub mock answers status code "017" to every request
    When the connector sends a remote start
    Then the failure is classified "configuration"
    And no automatic retry is scheduled
    And an alert names the ProviderID and certificate subject

  @RH-HUBJECT-SEC-003 @mock
  Scenario Outline: Environment selects the base URL
    Given the environment is "<env>"
    Then the base URL is "<url>"

    Examples:
      | env  | url                                      |
      | qa   | https://service-qa.hubject.com/api/oicp  |
      | prod | https://service.hubject.com/api/oicp     |

  @RH-HUBJECT-SEC-004 @pending-confirmation
  Scenario: Only supported service versions are used
    Given the pinned EMP contract lists authorize "v21", cdr "v22", evse data "v23"
    Then the connector refuses to start with a service version that is not in the contract

  @RH-HUBJECT-SEC-004 @mock
  Scenario: Connector declares the OICP version and refuses retired service versions
    Given the connector is configured for OICP 2.3
    Then the version is declared to Hubject on onboarding
    And a call to a service version of a retired OICP version is rejected by the client

  @RH-HUBJECT-SEC-005 @sandbox
  Scenario: Inbound calls only from Hubject source IPs
    Given the allow-list holds the Hubject QA source IPs for the QA environment
    When a call arrives from another IP
    Then it is refused
    And outbound calls leave from the registered static IP

  @RH-HUBJECT-SEC-006 @mock
  Scenario: CSRs are separate per environment
    When the operator generates CSRs for QA and PROD
    Then each has O "Hubject" and CN equal to the service domain
    And the two private keys differ
