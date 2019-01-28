module Analytics
  module CustomVariable
    CUSTOM_VARIABLES = {
      rp: { name: 'RP', index: 1 },
      loa_requested: { name: 'LOA_REQUESTED', index: 2 },
      journey_type: { name: 'JOURNEY_TYPE', index: 3 },
      cycle_three_attribute: { name: 'CYCLE_3', index: 4 },
      idp_selection: { name: 'IDP_SELECTION', index: 5 },
      ab_test: { name: 'AB_TEST', index: 6 },
      session_value: { name: 'SESSION_VALUE', index: 7 },
      uuid: { name: 'UUID', index: 8 },
    }.freeze

    def self.build(type, value)
      name, index = CUSTOM_VARIABLES[type].values_at(:name, :index)
      { index => [name, value] }
    end

    def self.build_for_js_client(type, value)
      {
          'index': CUSTOM_VARIABLES[type][:index],
          'name': CUSTOM_VARIABLES[type][:name],
          'value': value,
          'scope': 'visit'
      }
    end
  end
end
