module Analytics
  module CustomVariable
    CUSTOM_VARIABLES = {
      select_idp: { name: 'SIGNIN_IDP', index: 3 },
      loa_requested: { name: 'LOA_REQUESTED', index: 2 },
      rp: { name: 'RP', index: 1 },
      idp_selection: { name: 'IDP_SELECTION', index: 5 },
      cycle_three_attribute: { name: 'CYCLE_3', index: 4 },
      ab_test: { name: 'AB_TEST', index: 6 },
    }.freeze

    def self.build(type, value)
      name, index = CUSTOM_VARIABLES[type].values_at(:name, :index)
      { index => [name, value] }
    end
  end
end
