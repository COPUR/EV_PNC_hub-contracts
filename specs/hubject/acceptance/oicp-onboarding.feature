Feature: Hubject onboarding gate
  @RH-HUBJECT-CERT-001 @RH-HUBJECT-CERT-002 @RH-HUBJECT-REG-002 @sandbox
  Scenario: QA E2E protocol cases
    Given RFID test UIDs were submitted to Hubject
    And Online and Broadcast Requests are enabled for Authorization in QA
    Then case 1 or 2 authorizes our RFID card at the VCP
    And case 3 starts a session at the VCP from our app
    And case 4 refuses a wrong credential
