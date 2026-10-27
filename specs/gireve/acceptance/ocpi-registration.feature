Feature: Registration, versions and routing with the GIREVE IOP
  @RH-GIREVE-REG-001 @RH-GIREVE-REG-003 @sandbox
  Scenario: Register against pre-production
    Given GIREVE has created our operator and issued temporary credentials and a client certificate
    And our egress IPs are on the allow-list
    When the platform registers with the IOP (FR*107)
    Then final tokens and endpoints are stored
    And the authorization token is Base64 encoded on every call

  @RH-GIREVE-REG-002 @mock
  Scenario: Credentials change forces unregister and register
    Given the platform is registered
    When an endpoint URL changes
    Then the platform unregisters and registers again
    And no credentials-update call is attempted

  @RH-GIREVE-REG-004 @mock
  Scenario: Routing and tracing headers
    When the platform sends a Locations GET for a CPO party
    Then the request has OCPI-to-* and OCPI-from-* headers
    And X-Request-ID and X-Correlation-ID are set
    And the response echoes both ids
    When the platform sends a credentials or versions request
    Then no routing headers are required

  @RH-GIREVE-VER-001 @mock
  Scenario: Platform speaks 2.2.1 to the hub
    When the platform selects a version from the IOP version list
    Then it selects "2.2.1"
    And payloads contain no 2.3.0-only modules or enum values

  @RH-GIREVE-REG-001 @sandbox
  Scenario: register-fromiop
    Given GIREVE holds our versions URL, the temporary token and the certificate it uses to call us
    When the IOP calls GET versions and POST credentials on our endpoints
    Then we answer with version "2.2.1" and our final token
    And we store the IOP token and endpoints from the POST

  @RH-GIREVE-REG-005 @mock
  Scenario: unregister-fromiop
    Given the IOP is registered
    When the IOP sends DELETE credentials
    Then the IOP credentials are removed
    And a new Register FromIOP is accepted

  @RH-GIREVE-SEC-002 @mock
  Scenario: inbound-mtls
    When a call reaches our OCPI endpoints without the IOP client certificate
    Then the TLS handshake fails before any OCPI processing

  @RH-GIREVE-VER-002 @mock
  Scenario: version-2.2.1
    Given a canonical OCPI 2.3.0 location with a 2.3.0-only field and the Payments module enabled
    When the platform sends it to GIREVE
    Then only OCPI 2.2.1 fields and modules are sent
    And the conversion follows ../../profiles/ocpi-2.3.0-to-2.2.1.conversion.yaml
