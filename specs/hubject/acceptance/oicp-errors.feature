Feature: OICP failure handling and happy paths (Hubject mock)
  Background:
    Given the connector runs as ProviderID "TR*XYZ" against the hub mock

  @happy @RH-HUBJECT-ERR-001 @mock
  Scenario: Authorized answer carries a listed StatusCode
    When the HBS posts authorize/start for a known contract
    Then the response has AuthorizationStatus "Authorized" and StatusCode "000"

  @error @RH-HUBJECT-ERR-001 @mock
  Scenario Outline: Every refusal uses a code from the official list
    Given the decision is a refusal of kind "<kind>"
    When the response is built
    Then StatusCode.Code is one of the official OICP 2.3 codes
    And AdditionalInfo is at most 1000 characters
    Examples:
      | kind            |
      | unknown uid     |
      | locked contract |
      | policy block    |
      | system fault    |

  @error @RH-HUBJECT-ERR-002 @mock
  Scenario: Business failure inside HTTP 200
    Given the hub mock answers HTTP 200 with Result false and StatusCode "603"
    When the connector sends a remote start
    Then the start is marked failed
    And the failure is not logged as a transport error

  @error @RH-HUBJECT-ERR-002 @mock
  Scenario: HTTP 429 is a transport failure
    Given the hub mock answers HTTP 429
    When the connector sends a remote start
    Then the failure is classified "rate limited" and retried with backoff

  @error @RH-HUBJECT-ERR-003 @mock
  Scenario: Status 017 is a configuration error
    Given the hub mock answers StatusCode "017"
    When the connector sends a remote stop
    Then no automatic retry is scheduled
    And an alert names the ProviderID and the certificate expiry date

  @error @RH-HUBJECT-ERR-003 @mock
  Scenario: Certificate expiry warning
    Given the client certificate expires in 14 days
    When the daily certificate check runs
    Then an alert is raised

  @happy @RH-HUBJECT-ERR-004 @RH-HUBJECT-CMD-001 @mock
  Scenario: Remote start accepted, no SessionID sent
    When the connector posts authorize-remote/start
    Then the request body has no SessionID
    And the HBS-assigned SessionID from the response is stored

  @error @RH-HUBJECT-ERR-004 @mock
  Scenario Outline: Remote start failure codes reach the driver
    Given the hub mock answers Result false with StatusCode "<code>"
    When the connector sends a remote start
    Then the app receives the message "<message key>"
    And no automatic retry is scheduled
    Examples:
      | code | message key         |
      | 210  | no_active_offer     |
      | 300  | operator_unknown    |
      | 501  | evse_unreachable    |
      | 510  | plug_in_cable       |
      | 601  | evse_reserved       |
      | 602  | evse_in_use         |
      | 603  | evse_unknown        |
      | 604  | evse_not_roamable   |
      | 700  | evse_out_of_service |

  @error @RH-HUBJECT-ERR-004 @mock
  Scenario: CPO unreachable gives a false result
    Given the hub mock answers Result false with a connection error message
    When the connector sends a remote start
    Then the start is marked failed with reason "charger offline"

  @error @RH-HUBJECT-ERR-005 @mock
  Scenario Outline: CPO silent past its window
    Given the hub mock delays its answer to remote <op> by 62 seconds then returns a TimeOut error
    When the connector sends the request
    Then the client waits at least 65 seconds
    And the session state is "unknown"
    And the connector does not resend automatically
    Examples:
      | op    |
      | start |
      | stop  |

  @error @RH-HUBJECT-CMD-002 @mock
  Scenario: Remote stop with an invalid session
    Given the hub mock answers a negative result for SessionID "00000000-0000-0000-0000-000000000000"
    When the connector sends a remote stop
    Then the stop is marked failed
    And no retry is scheduled

  @happy @RH-HUBJECT-ERR-006 @RH-HUBJECT-CDR-001 @mock
  Scenario: CDR received and stored
    When the HBS posts a charge-detail-record for SessionID "S-6"
    Then the response has Result true and StatusCode "000"
    And one canonical CDR exists for "S-6"

  @error @RH-HUBJECT-ERR-006 @mock
  Scenario: Duplicate CDR
    When the HBS posts the same charge-detail-record twice
    Then both responses have Result true
    And exactly one canonical CDR exists

  @error @RH-HUBJECT-ERR-006 @mock
  Scenario: CDR lost while we were down
    Given the connector was unreachable when the HBS forwarded the CDR for "S-7"
    When the post-outage reconciliation calls get-charge-detail-records-request with CDRForwarded false
    Then a CDR for "S-7" is stored once

  @happy @RH-HUBJECT-ERR-007 @RH-HUBJECT-CDR-003 @mock
  Scenario: Notification sequence acknowledged
    When the HBS posts Start, Progress and End notifications for "S-8"
    Then each response has Result true
    And session "S-8" is closed after End

  @error @RH-HUBJECT-ERR-007 @mock
  Scenario Outline: Error notification tells the driver what to do
    When the HBS posts an Error notification with ErrorType "<type>"
    Then the app message key is "<message key>"
    Examples:
      | type          | message key        |
      | ConnectorError | check_plug        |
      | CriticalError  | use_other_station |

  @error @RH-HUBJECT-ERR-007 @mock
  Scenario: End without CDR releases the one-session lock
    Given a pre-authorised session "S-9" with no CDR
    When the HBS posts an End notification for "S-9"
    Then the driver can start a new session

  @happy @RH-HUBJECT-ERR-008 @RH-HUBJECT-LOC-003 @mock
  Scenario: Paged EVSE pull
    When the connector pulls EVSE data
    Then every request carries size 2000
    And paging stops when "last" is true

  @error @RH-HUBJECT-ERR-008 @mock
  Scenario: Null fields from an older-version CPO
    Given the hub mock returns an EVSE record with null PaymentOptions
    When the connector ingests it
    Then the record is stored with a data-quality flag and no exception

  @error @RH-HUBJECT-ERR-008 @mock
  Scenario: Non-roamable EVSE is hidden
    Given the hub mock returns an EVSE with IsHubjectCompatible false
    Then the EVSE is not offered for remote start

  @error @RH-HUBJECT-ERR-013 @mock
  Scenario: Unsubscribed operator is not offered
    Given the eMSP has no subscription with operator "TR*NEW"
    Then EVSEs of "TR*NEW" are not offered for remote start
