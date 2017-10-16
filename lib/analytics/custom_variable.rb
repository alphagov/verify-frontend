module Analytics
  module CustomVariable
    CUSTOM_VARIABLES = {
      rp: { name: 'RP', index: 1 },
      loa_requested: { name: 'LOA_REQUESTED', index: 2 },
      journey_type: { name: 'JOURNEY_TYPE', index: 3 },
      cycle_three_attribute: { name: 'CYCLE_3', index: 4 },
      idp_selection: { name: 'IDP_SELECTION', index: 5 },
      ab_test: { name: 'AB_TEST', index: 6 },
    }.freeze

    def self.build(type, value)
      name, index = CUSTOM_VARIABLES[type].values_at(:name, :index)
      { index => [name, value] }
    end
  end
end
