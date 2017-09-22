LOA1_SHORTENED_JOURNEY_EXPERIMENT = 'loa1_shortened_journey'.freeze

loa1_shortened_control_piwik = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'control', RoutesHelper::ReportToPiwik)
loa1_shortened_variant_extra_text_button_piwik = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant_extra_text_button', RoutesHelper::ReportToPiwik)
loa1_shortened_variant_continue_button_piwik = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant_continue_button', RoutesHelper::ReportToPiwik)

loa1_shortened_control = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'control')
loa1_shortened_variant_extra_text_button = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant_extra_text_button')
loa1_shortened_variant_continue_button = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant_continue_button')


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

constraints loa1_shortened_variant_extra_text_button_piwik do
  get 'start', to: 'start_variant_extra_text_button#index', as: :start_loa1
end

constraints loa1_shortened_variant_extra_text_button do
  post 'start', to: 'start_variant_extra_text_button#request_post', as: :start_loa1

  get 'sign_in', to: 'sign_in_variant_extra_text_button#index', as: :sign_in
  post 'sign_in', to: 'sign_in_variant_extra_text_button#select_idp', as: :sign_in_submit

  get 'choose_a_certified_company', to: 'company_picker_variant_extra_text_button#index', as: :choose_a_certified_company
  post 'choose_a_certified_company', to: 'company_picker_variant_extra_text_button#select_idp', as: :choose_a_certified_company_submit

  get 'why_companies', to: 'why_companies_variant_extra_text_button#index', as: :why_companies
end

constraints loa1_shortened_variant_continue_button_piwik do
  get 'start', to: 'start_variant_continue_button#index', as: :start_loa1
end

constraints loa1_shortened_variant_continue_button do
  post 'start', to: 'start_variant_continue_button#request_post', as: :start_loa1

  get 'sign_in', to: 'sign_in_variant_continue_button#index', as: :sign_in
  post 'sign_in', to: 'sign_in_variant_continue_button#select_idp', as: :sign_in_submit

  get 'choose_a_certified_company', to: 'company_picker_variant_continue_button#index', as: :choose_a_certified_company
  post 'choose_a_certified_company', to: 'company_picker_variant_continue_button#select_idp', as: :choose_a_certified_company_submit

  get 'why_companies', to: 'why_companies_variant_continue_button#index', as: :why_companies
end
