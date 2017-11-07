LOA1_RADIO_PICKER_EXPERIMENT = 'loa1_radio_picker'.freeze

loa1_radio_picker_control_piwik = SelectRoute.new(LOA1_RADIO_PICKER_EXPERIMENT, 'control', true)
loa1_radio_picker_variant_piwik = SelectRoute.new(LOA1_RADIO_PICKER_EXPERIMENT, 'variant', true)

loa1_radio_picker_control = SelectRoute.new(LOA1_RADIO_PICKER_EXPERIMENT, 'control')
loa1_radio_picker_variant = SelectRoute.new(LOA1_RADIO_PICKER_EXPERIMENT, 'variant')

constraints loa1_radio_picker_control_piwik do
  get 'choose_a_certified_company', to: 'choose_a_certified_company_loa1#index', as: :choose_a_certified_company
end

constraints loa1_radio_picker_variant_piwik do
  get 'choose_a_certified_company', to: 'choose_a_certified_company_loa1_variant_radio#index', as: :choose_a_certified_company
end

constraints loa1_radio_picker_control do
  constraints IsLoa1 do
    post 'choose_a_certified_company', to: 'choose_a_certified_company_loa1#select_idp', as: :choose_a_certified_company_submit
    get 'choose_a_certified_company_about', to: 'choose_a_certified_company_loa1#about', as: :choose_a_certified_company_about
  end
end

constraints loa1_radio_picker_variant do
  constraints IsLoa1 do
    post 'choose_a_certified_company', to: 'choose_a_certified_company_loa1_variant_radio#select_idp', as: :choose_a_certified_company_submit
    put 'choose_a_certified_company', to: 'choose_a_certified_company_loa1_variant_radio#select_idp_ajax', as: :choose_a_certified_company_submit_ajax    
  end
end
