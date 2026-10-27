Feature: GIREVE failure and happy flows
  @happy @RH-GIREVE-TOK-001 @mock
  Scenario: known-token
    When the IOP posts authorize for our token "04A1B2C3D4E5F6"
    Then we answer 1000 with allowed "ALLOWED"

  @error @RH-GIREVE-ERR-001 @mock
  Scenario: unknown-token
    When the IOP posts authorize for uid "FFFFFFFF"
    Then we answer status_code 2004 with no data

  @error @RH-GIREVE-ERR-002 @mock
  Scenario: refused-token
    Given token "04A1B2C3" is blocked
    When the IOP posts authorize for it
    Then allowed is "BLOCKED"

  @happy @RH-GIREVE-CMD-001 @mock
  Scenario: start-ok
    When START_SESSION gets CommandResponse ACCEPTED and CommandResult ACCEPTED
    Then the app shows "charging"

  @error @RH-GIREVE-ERR-003 @mock
  Scenario: command-timeout
    Given CommandResponse ACCEPTED with timeout 60
    When no CommandResult arrives within 60 seconds
    Then the app shows "start not confirmed"

  @error @RH-GIREVE-ERR-004 @mock
  Scenario Outline: hub-errors
    When the IOP answers <code> to START_SESSION
    Then the driver sees "<message>"
    Examples:
      | code | message                |
      | 4001 | operator not reachable |
      | 4002 | operator timed out     |
      | 4003 | operator not connected |

  @error @RH-GIREVE-ERR-005 @mock
  Scenario: registration-errors
    Given our GET versions to the IOP fails during its POST credentials
    Then we answer the POST with 3001

  @happy @RH-GIREVE-ERR-006 @mock
  Scenario: pagination
    When we pull locations without limit
    Then we follow each Link until none remains

  @error @RH-GIREVE-ERR-007 @mock
  Scenario: pncp-token-expired
    Given the cached PNCP token has expired
    When a Build Sign Store call is needed
    Then one token request is made before the call

  @error @RH-GIREVE-ERR-008 @mock
  Scenario: cdr-replay
    When the same CDR arrives twice
    Then one CDR is stored

  @error @RH-GIREVE-ERR-009 @mock
  Scenario: price-not-significant
    When a CDR with remark "[?] no B2B price" arrives
    Then we compute the price from the REGULAR tariff

  @error @RH-GIREVE-REG-002 @mock
  Scenario: no-credentials-update
    When our endpoint URL changes
    Then no PUT credentials is sent and we ask GIREVE to unregister and register again

  @error @RH-GIREVE-PNC-006 @mock
  Scenario: webhook-bad-signature
    When a webhook arrives with a wrong payload-signature
    Then it is rejected and nothing is processed

  @error @RH-GIREVE-PNC-003 @mock
  Scenario: key-reuse
    When renewal is attempted with the old key pair
    Then it is stopped locally

  @error @RH-GIREVE-PNC-011 @mock
  Scenario: pc-revoked
    When webhook "emsp.provisionning.certificate.revoked" arrives for an undelivered SCCB
    Then Build Sign Store is called again when the new PC is available

  @happy @RH-GIREVE-PNC-013 @mock
  Scenario: renewal
    When "emsp.contract.certificate.expiring.soon" arrives
    Then the certificate is renewed with the same eMAID

  @error @RH-GIREVE-ERR-010 @mock
  Scenario: no-reservation-or-unlock
    Given a GIREVE-roamed EVSE
    Then the app offers neither reservation nor unlock
