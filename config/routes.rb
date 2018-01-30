include LoaMatch

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  def add_routes(routes_name)
    instance_eval(File.read(Rails.root.join("config/#{routes_name}.rb")))
  end

  post 'SAML2/SSO' => 'authn_request#rp_request'
  post 'SAML2/SSO/Response/POST' => 'authn_response#idp_response'
  post 'SAML2/SSO/EidasResponse/POST' => 'authn_response#country_response'
  match "/404", to: "errors#page_not_found", via: :all

  if %w(test development).include? Rails.env
    mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
    get 'test-saml' => 'test_saml#index'
    post 'test-rp', to: proc { |_| [200, {}, ['OK']] }
    post 'test-idp-request-endpoint' => 'test_saml#idp_request'
    post 'another-idp-endpoint' => 'test_saml#idp_request'
    get 'test-journey-hint' => 'test_journey_hint_cookie#index', as: :test_journey_hint
    post 'test-journey-hint' => 'test_journey_hint_cookie#set_cookie', as: :test_journey_hint_submit
    # route analytics through frontend URI, as like prod, to not violate our csp policy
    get 'analytics', to: 'test_analytics#forward'
    # fake basic csp reporter so reports can be logged (in development.log)
    # has to be routed through the frontend as currently Firefox requires the reporter
    # to be hosted in the same place as the place serving the pages
    # see: https://developer.mozilla.org/en-US/docs/Web/Security/CSP/CSP_policy_directives#report-uri
    # to use, add ';report-uri http://127.0.0.1:50300/csp-reporter' to the end of the CSP header in application.rb
    post 'csp-reporter', to: 'test_csp_reporter#report'
  end

  localized do
    add_routes :main_routes
  end

  # HUB-2 delete if tearing the AB test down:
  put 'start-select-idp', to: 'start_idp_focused_variant#select_idp_ajax', as: :start_select_idp_submit_ajax

  put 'redirect-to-idp-warning', to: 'redirect_to_idp_warning#continue_ajax', as: :redirect_to_idp_warning_submit_ajax
  put 'select-idp', to: 'sign_in#select_idp_ajax', as: :select_idp_submit_ajax
  get 'service-status', to: 'service_status#index', as: :service_status
  get '/assets2/fp.gif', to: proc { |_| [200, {}, ['OK']] }
  get '/SAML2/metadata/sp', to: 'metadata#service_providers', as: :service_provider_metadata
  get '/SAML2/metadata/idp', to: 'metadata#identity_providers', as: :identity_provider_metadata
  get '/humans.txt', to: 'static#humanstxt'
end
