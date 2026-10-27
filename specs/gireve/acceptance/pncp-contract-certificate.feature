Feature: Plug&Charge contract certificates through GIREVE PNCP
  Background:
    Given PNCP client credentials are configured (mock, or preproduction with an allow-listed IP)

  @RH-GIREVE-PNC-002 @mock
  Scenario: Token is reused until expiry
    When the platform calls two PNCP operations within the token lifetime
    Then one OAuth2 token request is made
    And both calls carry PNCP-from-country-code and PNCP-from-party-id

  @RH-GIREVE-PNC-003 @mock
  Scenario: Renewal needs a new key pair
    When the platform renews a certificate reusing the old key
    Then the request is rejected locally before sending

  @RH-GIREVE-PNC-005 @mock
  Scenario: Authorize with eMAID
    When the IOP posts tokens/authorize with auth_id "FR*XYZ*C00001*1" and type "OTHER"
    Then the platform resolves the contract and answers AuthorizationInfo

  @RH-GIREVE-PNC-006 @mock
  Scenario: Webhook signature verified
    When a webhook arrives with a valid HMAC-SHA256 payload-signature
    Then it is processed
    When a webhook arrives with an invalid signature
    Then it is rejected with 401 and logged

  @RH-GIREVE-SEC-001 @mock
  Scenario: Secrets never reach logs
    When the platform performs a token request and a contract certificate request
    Then no log line contains the client secret, bearer token or private key material

  @RH-GIREVE-PNC-001 @RH-GIREVE-PNC-009 @mock
  Scenario: build-sign-store
    Given a customer with an eMAID under our TR party and a vehicle PCID
    When Plug&Charge is activated
    Then one Build Sign Store call carries both values and our assigned profile

  @RH-GIREVE-PNC-009 @mock
  Scenario: emaid-format
    When an eMAID with another provider ID is generated
    Then the call is blocked locally

  @RH-GIREVE-PNC-011 @mock
  Scenario: pc-changed
    Given an SCCB for PCID "P1" not yet delivered
    When webhook "emsp.provisionning.certificate.updated" arrives for "P1"
    Then Build Sign Store is called again for the same eMAID

  @RH-GIREVE-PNC-004 @mock
  Scenario: delivered-not-installed
    When webhook "emsp.contract.certficate.delivered" arrives
    Then the contract shows "delivered to charger", not "installed"

  @RH-GIREVE-PNC-012 @mock
  Scenario: deactivate
    When the customer cancels Plug&Charge
    Then "Deactivate an eMAId" is called for the eMAID

  @RH-GIREVE-PNC-013 @mock
  Scenario: renew
    When webhook "emsp.contract.certificate.expiring.soon" arrives
    Then Build Sign Store is called with the same eMAID

  @RH-GIREVE-PNC-008 @mock
  Scenario: mtls
    Then PNCP calls go to "pp-trust-secure-api.gireve.com" with a client certificate and a bearer token

  @RH-GIREVE-TOK-005 @RH-GIREVE-PNC-001 @mock
  Scenario: emaid-authorize
    Given a contract with eMAID "TRXYZC00000011"
    When the IOP forwards an authorize for a token of type OTHER with that uid
    Then the platform matches the contract by eMAID
    And pushes of Plug&Charge tokens are never sent

  @RH-GIREVE-PNC-010 @mock
  Scenario: pcid-check
    Given the customer enters an unknown PCID
    When the platform calls "Check a PCID in PCP"
    Then the customer is told the vehicle is not yet available for Plug&Charge

  @RH-GIREVE-PNC-014 @mock
  Scenario: iso-version
    Given a vehicle that supports only ISO 15118-20
    Then GIREVE-issued Plug&Charge is not offered

  @RH-GIREVE-PNC-015 @mock
  Scenario: profile
    When the platform calls Build Sign Store
    Then the certificate profile id comes from configuration and is one GIREVE assigned
