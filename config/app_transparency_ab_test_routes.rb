APP_TRANSPARENCY_EXPERIMENT = 'app_transparency_v2'.freeze

app_transparency_control_piwik = SelectRoute.new(APP_TRANSPARENCY_EXPERIMENT, 'control', RoutesHelper::ReportToPiwik)
app_transparency_variant_piwik = SelectRoute.new(APP_TRANSPARENCY_EXPERIMENT, 'variant', RoutesHelper::ReportToPiwik)

app_transparency_control = SelectRoute.new(APP_TRANSPARENCY_EXPERIMENT, 'control')
app_transparency_variant = SelectRoute.new(APP_TRANSPARENCY_EXPERIMENT, 'variant')

constraints app_transparency_control_piwik do
  get 'select_phone', to: 'select_phone#index', as: :select_phone
end

constraints app_transparency_variant_piwik do
  get 'select_phone', to: 'select_phone_variant#index', as: :select_phone
end

constraints app_transparency_control do
  post 'select_phone', to: 'select_phone#select_phone', as: :select_phone_submit

  get 'choose_a_certified_company', to: 'choose_a_certified_company#index', as: :choose_a_certified_company
  post 'choose_a_certified_company', to: 'choose_a_certified_company#select_idp', as: :choose_a_certified_company_submit
end

constraints app_transparency_variant do
  post 'select_phone', to: 'select_phone_variant#select_phone', as: :select_phone_submit

  get 'choose_a_certified_company', to: 'choose_a_certified_company_variant#index', as: :choose_a_certified_company
  post 'choose_a_certified_company', to: 'choose_a_certified_company_variant#select_idp', as: :choose_a_certified_company_submit
end
