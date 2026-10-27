Feature: CDR reconciliation
  @RH-HUBJECT-CDR-004 @mock
  Scenario: A CDR missed during downtime is recovered
    Given the eMSP was down when the HBS forwarded the CDR for "S-5"
    When the daily reconciliation calls get-charge-detail-records-request with CDRForwarded false
    Then exactly one canonical CDR exists for "S-5"
