module Analytics
  module CustomVariable
    CUSTOM_VARIABLES = {
      select_idp: { name: 'SIGNIN_IDP', index: 3 },
      register_idp: { name: 'REGISTER_IDP', index: 2 },

      rp: { name: 'RP', index: 1 }
    }.freeze

    def self.build(type, value)
      name, index = CUSTOM_VARIABLES[type].values_at(:name, :index)
      { index => [name, value] }
    end
  end
end
