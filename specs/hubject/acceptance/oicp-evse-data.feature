Feature: EVSE data and status from Hubject
  @RH-HUBJECT-LOC-001 @mock
  Scenario: EVSE data maps to canonical locations
    Given the hub mock returns EVSE data records for operator "DE*ABC"
    When the connector pulls EVSE data (v2.3) and EVSE status (v2.1)
    Then every record is stored as a canonical Location, EVSE and Connector
    And the mapping table generated in T-HUBJECT-08 is applied without unmapped mandatory fields

  @RH-HUBJECT-LOC-003 @mock
  Scenario: Full pull walks all pages
    Given the hub mock holds 4500 EVSE records
    When the connector pulls EVSE data with size 2000
    Then it requests pages 0, 1 and 2 and stops when "last" is true

  @RH-HUBJECT-LOC-004 @mock
  Scenario: Status by operator for subscribed CPOs
    Given the eMSP subscribes to operator "TR*ZES"
    When the status job runs
    Then it posts to "status-records-by-operator-id" with OperatorID ["TR*ZES"]
