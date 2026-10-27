Feature: OPCP webhooks
  @RH-HUBJECT-PNC-006 @mock
  Scenario Outline: Valid signature in any documented header
    Given the endpoint secret "s3cr3t"
    When a webhook arrives with header "<header>" set to "sha256=" + HMAC-SHA256(body, "s3cr3t")
    Then the response status is 200
    Examples:
      | header               |
      | X-Hubject-Signature  |
      | X-Operator-Signature |
      | payload-signature    |

  @RH-HUBJECT-PNC-006 @mock
  Scenario: Wrong signature is rejected
    When a webhook arrives with a signature computed with another secret
    Then the response status is 401 and the event is not processed

  @RH-HUBJECT-PNC-008 @mock
  Scenario: Factory reset invalidates contracts
    Given PCID "ABC12345678901234" has contract EMAID "TRXYZC00000011"
    When a valid "mo.prov.cert.factory.reset" event for that PCID arrives twice with the same eventId
    Then the contract is marked invalid once
    And no new contract can be created for that PCID
