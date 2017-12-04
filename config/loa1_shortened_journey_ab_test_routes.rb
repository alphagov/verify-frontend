LOA1_SHORTENED_JOURNEY_EXPERIMENT = 'loa1_shortened_journey_v3'.freeze

loa1_shortened_journey_control_piwik = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'control', is_start_of_test: true, experiment_loa: 'LEVEL_1')
loa1_shortened_journey_variant_piwik = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant', is_start_of_test: true, experiment_loa: 'LEVEL_1')

loa1_shortened_journey_control = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'control')
loa1_shortened_journey_variant = SelectRoute.new(LOA1_SHORTENED_JOURNEY_EXPERIMENT, 'variant')

constraints loa1_shortened_journey_control_piwik do
  get 'start', to: 'start#index', as: :start
end

constraints loa1_shortened_journey_variant_piwik do
  get 'start', to: 'start_variant#index', as: :start
end

constraints loa1_shortened_journey_control do
  constraints IsLoa1 do
    post 'start', to: 'start#request_post', as: :start
    get 'begin_registration', to: 'start#register', as: :begin_registration
  end
end

constraints loa1_shortened_journey_variant do
  constraints IsLoa1 do
    get 'begin_sign_in', to: 'start_variant#sign_in', as: :begin_sign_in
    get 'begin_registration', to: 'start_variant#register', as: :begin_registration
  end
end
