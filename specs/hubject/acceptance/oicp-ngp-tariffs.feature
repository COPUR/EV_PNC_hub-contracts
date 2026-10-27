Feature: NGP tariffs
  @RH-HUBJECT-TARIFF-001 @mock
  Scenario: B2B price per EVSE group feeds the policy
    Given the Enhanced Contracts mock returns group "G1" with CHARGING_ENERGY 8.00 TRY per KILOWATT_HOUR on MONDAY 00:00-23:59
    And Contracts EVSEs lists "TR*ZES*E1" in "G1"
    When the HBS posts authorize/start for EVSE "TR*ZES*E1" on a Monday
    Then the policy engine receives a B2B energy price of 8.00 TRY/kWh excluding tax
