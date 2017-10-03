LOA1_SHORTENED_JOURNEY_EXPERIMENT = 'loa1_shortened_journey'.freeze

loa1_shortened_control_piwik = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'control', RoutesHelper::ReportToPiwik, 'LEVEL_1')
loa1_shortened_variant_get_setup_piwik = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant_get_setup', RoutesHelper::ReportToPiwik, 'LEVEL_1')
loa1_shortened_variant_create_account_piwik = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant_create_account', RoutesHelper::ReportToPiwik, 'LEVEL_1')

loa1_shortened_control = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'control')
loa1_shortened_variant_get_setup = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant_get_setup')
loa1_shortened_variant_create_account = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant_create_account')


constraints loa1_shortened_control_piwik do
  get 'start', to: 'start#index', as: :start
end

constraints loa1_shortened_control do
  post 'start', to: 'start#request_post', as: :start

  get 'sign_in', to: 'sign_in#index', as: :sign_in
  post 'sign_in', to: 'sign_in#select_idp', as: :sign_in_submit

  get 'choose_a_certified_company', to: 'choose_a_certified_company#index', as: :choose_a_certified_company
  post 'choose_a_certified_company', to: 'choose_a_certified_company#select_idp', as: :choose_a_certified_company_submit

  get 'why_companies', to: 'why_companies#index', as: :why_companies
end

constraints loa1_shortened_variant_get_setup_piwik do
  get 'start', to: 'start_variant_get_setup#index', as: :start_loa1
end

constraints loa1_shortened_variant_get_setup do
  post 'start', to: 'start_variant_get_setup#request_post', as: :start_loa1

  get 'sign_in', to: 'sign_in_variant_get_setup#index', as: :sign_in
  post 'sign_in', to: 'sign_in_variant_get_setup#select_idp', as: :sign_in_submit

  get 'choose_a_certified_company', to: 'choose_a_certified_company_variant_get_setup#index', as: :choose_a_certified_company
  post 'choose_a_certified_company', to: 'choose_a_certified_company_variant_get_setup#select_idp', as: :choose_a_certified_company_submit

  get 'why_companies', to: 'why_companies_variant_get_setup#index', as: :why_companies
end

constraints loa1_shortened_variant_create_account_piwik do
  get 'start', to: 'start_variant_create_account#index', as: :start_loa1
end

constraints loa1_shortened_variant_create_account do
  post 'start', to: 'start_variant_create_account#request_post', as: :start_loa1

  get 'sign_in', to: 'sign_in_variant_create_account#index', as: :sign_in
  post 'sign_in', to: 'sign_in_variant_create_account#select_idp', as: :sign_in_submit

  get 'choose_a_certified_company', to: 'choose_a_certified_company_variant_create_account#index', as: :choose_a_certified_company
  post 'choose_a_certified_company', to: 'choose_a_certified_company_variant_create_account#select_idp', as: :choose_a_certified_company_submit

  get 'why_companies', to: 'why_companies_variant_create_account#index', as: :why_companies
end
