  @RH-GIREVE-TARIFF-002 @mock
  Scenario: Tariff pull limits
    When the platform pulls tariffs for a 45 day window
    Then it issues two requests of at most one month each
    And each page holds at most 100 tariffs

  @RH-GIREVE-LOC-001 @mock
  Scenario: Hub extension and loose EVSE ids
    When a Location arrives with gireve_id and a non-compliant evse_id
    Then it is stored with gireve_id and the evse_id is not rejected

  @RH-GIREVE-LOC-002 @mock
  Scenario: Plug&Charge capability is detected
    When a connector has capability "ISO_15118_2_PLUG_AND_CHARGE"
    Then the EVSE is marked Plug&Charge capable for the planner

  @RH-GIREVE-TARIFF-001 @mock
  Scenario: b2b-only
    When tariffs are received from the IOP
    Then only type REGULAR or untyped tariffs are expected
    And no AD_HOC_PAYMENT tariff is required for guest pricing

  @RH-GIREVE-TARIFF-003 @mock
  Scenario: targeted-tariff
    Given tariff "T1" exists untargeted and targeted to our party
    When pricing a session that references "T1"
    Then the targeted version is used

  @RH-GIREVE-VER-003 @mock
  Scenario: field-widths
    When a Location with a 200-character address arrives
    Then it is stored without truncation
