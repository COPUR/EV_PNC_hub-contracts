Feature: Tokens, commands, sessions and CDRs via the IOP
  @RH-GIREVE-TOK-001 @mock
  Scenario: Real-time authorize
    Given an RFID token "04A1B2C3D4E5F6" of our contract
    When the IOP posts tokens/04A1B2C3D4E5F6/authorize with a Location reference
    Then the response contains AuthorizationInfo with allowed "ALLOWED"
    And the Location reference is echoed

  @RH-GIREVE-TOK-002 @mock
  Scenario: EMAID tokens are never pushed
    Given contract "FR*XYZ*C00001*1" has a Plug&Charge token of type EMAID
    When the token sync runs
    Then no push contains that token

  @RH-GIREVE-TOK-003 @mock
  Scenario Outline: UID normalisation
    When the platform pushes RFID UID "<input>"
    Then the IOP receives "<output>"

    Examples:
      | input        | output         |
      | 04a1b2c3     | 04A1B2C3       |
      | 4a1b2c3d4e5f6 | 04A1B2C3D4E5F6 |

  @RH-GIREVE-TOK-004 @mock
  Scenario: Token changes are full PUTs
    When a token is blocked
    Then the platform sends a full token object, not a PATCH

  @RH-GIREVE-CMD-001 @mock
  Scenario: Start session needs evse_uid
    When the app starts a session at EVSE "FR*ABC*E1"
    Then START_SESSION is sent with evse_uid "FR*ABC*E1"
    And the OCPI-to headers address the CPO

  @RH-GIREVE-CMD-002 @mock
  Scenario: Unsupported commands are not offered
    When the app asks to reserve an EVSE roamed via GIREVE
    Then the app is told reservation is not available

  @RH-GIREVE-SESSION-001 @RH-GIREVE-CDR-001 @mock
  Scenario: Replayed CDR is idempotent
    When the IOP delivers the same CDR twice with remark prefix "[*]"
    Then one canonical CDR exists
    And the CDR is flagged "priced by hub"
    And our own total check still runs

  @RH-GIREVE-SESSION-002 @mock
  Scenario: session-gaps
    Given an ACTIVE session
    When no update arrives for 10 minutes and then a COMPLETED session arrives
    Then the session closes normally and no pull request is sent
