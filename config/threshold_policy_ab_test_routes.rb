THRESHOLD_POLICY_EXPERIMENT = 'threshold_policy_experiment'.freeze

threshold_policy_control_piwik = SelectRoute.new(THRESHOLD_POLICY_EXPERIMENT, 'control', true)
threshold_policy_variant_piwik = SelectRoute.new(THRESHOLD_POLICY_EXPERIMENT, 'variant', true)

threshold_policy_control = SelectRoute.new(THRESHOLD_POLICY_EXPERIMENT, 'control')
threshold_policy_variant = SelectRoute.new(THRESHOLD_POLICY_EXPERIMENT, 'variant')

constraints threshold_policy_control_piwik do
  get 'choose_a_certified_company', to: 'choose_a_certified_company_loa2#index', as: :choose_a_certified_company
end

constraints threshold_policy_variant_piwik do
  get 'choose_a_certified_company', to: 'choose_a_certified_company_loa2_variant#index', as: :choose_a_certified_company
end

constraints threshold_policy_control do
  get 'select_phone', to: 'select_phone#index', as: :select_phone
  post 'select_phone', to: 'select_phone#select_phone', as: :select_phone_submit

  constraints IsLoa2 do
    post 'choose_a_certified_company', to: 'choose_a_certified_company_loa2#select_idp', as: :choose_a_certified_company_submit
    get 'choose_a_certified_company/:company', to: 'choose_a_certified_company_loa2#about', as: :choose_a_certified_company_about
  end
end

constraints threshold_policy_variant do
  get 'select_phone', to: 'select_phone_variant#index', as: :select_phone
  post 'select_phone', to: 'select_phone_variant#select_phone', as: :select_phone_submit

  constraints IsLoa2 do
    post 'choose_a_certified_company', to: 'choose_a_certified_company_loa2_variant#select_idp', as: :choose_a_certified_company_submit
    get 'choose_a_certified_company/:company', to: 'choose_a_certified_company_loa2_variant#about', as: :choose_a_certified_company_about
  end
end
