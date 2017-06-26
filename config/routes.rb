Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  EXPERIMENT_NAME = 'app_transparency'.freeze

  report_to_piwik = -> (experiment_name, reported_alternative, transaction_id, request) {
    AbTest.report(experiment_name, reported_alternative, transaction_id, request)
  }

  route_a = SelectRoute.route_a(EXPERIMENT_NAME)
  route_b = SelectRoute.route_b(EXPERIMENT_NAME)
  route_a_and_report_to_piwik = SelectRoute.route_a(EXPERIMENT_NAME, report_to_piwik)
  route_b_and_report_to_piwik = SelectRoute.route_b(EXPERIMENT_NAME, report_to_piwik)

  post 'SAML2/SSO' => 'authn_request#rp_request'
  post 'SAML2/SSO/Response/POST' => 'authn_response#idp_response'
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
    get 'start', to: 'start#index', as: :start
    post 'start', to: 'start#request_post', as: :start
    get 'sign_in', to: 'sign_in#index', as: :sign_in
    post 'sign_in', to: 'sign_in#select_idp', as: :sign_in_submit
    get 'about', to: 'about#index', as: :about
    get 'about_certified_companies', to: 'about#certified_companies', as: :about_certified_companies
    get 'about_identity_accounts', to: 'about#identity_accounts', as: :about_identity_accounts
    get 'about_choosing_a_company', to: 'about#choosing_a_company', as: :about_choosing_a_company
    get 'select_documents', to: 'select_documents#index', as: :select_documents
    post 'select_documents', to: 'select_documents#select_documents', as: :select_documents_submit
    get 'unlikely_to_verify', to: 'select_documents#unlikely_to_verify', as: :unlikely_to_verify
    get 'other_identity_documents', to: 'other_identity_documents#index', as: :other_identity_documents
    post 'other_identity_documents', to: 'other_identity_documents#select_other_documents', as: :other_identity_documents_submit
    # get 'select_phone', to: 'select_phone#index', as: :select_phone
    # post 'select_phone', to: 'select_phone#select_phone', as: :select_phone_submit
    get 'no_mobile_phone', to: 'select_phone#no_mobile_phone', as: :no_mobile_phone
    get 'will_it_work_for_me', to: 'will_it_work_for_me#index', as: :will_it_work_for_me
    post 'will_it_work_for_me', to: 'will_it_work_for_me#will_it_work_for_me', as: :will_it_work_for_me_submit
    get 'why_might_this_not_work_for_me', to: 'will_it_work_for_me#why_might_this_not_work_for_me', as: :why_might_this_not_work_for_me
    get 'may_not_work_if_you_live_overseas', to: 'will_it_work_for_me#may_not_work_if_you_live_overseas', as: :may_not_work_if_you_live_overseas
    get 'will_not_work_without_uk_address', to: 'will_it_work_for_me#will_not_work_without_uk_address', as: :will_not_work_without_uk_address
    # get 'choose_a_certified_company', to: 'choose_a_certified_company#index', as: :choose_a_certified_company
    # post 'choose_a_certified_company', to: 'choose_a_certified_company#select_idp', as: :choose_a_certified_company_submit
    get 'choose_a_certified_company_about', to: 'choose_a_certified_company#about', as: :choose_a_certified_company_about
    get 'why_companies', to: 'why_companies#index', as: :why_companies
    get 'redirect_to_idp_warning', to: 'redirect_to_idp_warning#index', as: :redirect_to_idp_warning
    post 'redirect_to_idp_warning', to: 'redirect_to_idp_warning#continue', as: :redirect_to_idp_warning_submit
    get 'redirect_to_idp_question', to: 'redirect_to_idp_question#index', as: :redirect_to_idp_question
    post 'redirect_to_idp_question', to: 'redirect_to_idp_question#continue', as: :redirect_to_idp_question_submit
    get 'privacy_notice', to: 'static#privacy_notice', as: :privacy_notice
    get 'cookies', to: 'static#cookies', as: :cookies
    get 'confirm_your_identity', to: 'confirm_your_identity#index', as: :confirm_your_identity
    get 'choose_a_country', to: 'choose_a_country#choose_a_country', as: :choose_a_country
    post 'choose_a_country', to: 'choose_a_country#choose_a_country_submit', as: :choose_a_country_submit
    get 'confirmation', to: 'confirmation#index', as: :confirmation
    get 'failed_registration', to: 'failed_registration#index', as: :failed_registration
    get 'failed_uplift', to: 'failed_uplift#index', as: :failed_uplift
    get 'failed_sign_in', to: 'failed_sign_in#index', as: :failed_sign_in
    get 'other_ways_to_access_service', to: 'other_ways_to_access_service#index', as: :other_ways_to_access_service
    get 'forgot_company', to: 'static#forgot_company', as: :forgot_company
    get 'response_processing', to: 'response_processing#index', as: :response_processing
    get 'redirect_to_idp', to: 'redirect_to_idp#index', as: :redirect_to_idp
    get 'redirect_to_service_signing_in' => 'redirect_to_service#signing_in', as: :redirect_to_service_signing_in
    get 'redirect_to_service_start_again' => 'redirect_to_service#start_again', as: :redirect_to_service_start_again
    get 'redirect_to_service_error' => 'redirect_to_service#error', as: :redirect_to_service_error
    get 'redirect_to_country' => 'redirect_to_country#index', as: :redirect_to_country
    post 'redirect_to_country', to: 'redirect_to_country#submit', as: :redirect_to_country
    post 'a_country_page' => 'a_country_page#index', as: :a_country_page
    get 'feedback', to: 'feedback#index', as: :feedback
    post 'feedback', to: 'feedback#submit', as: :feedback_submit
    get 'feedback_sent', to: 'feedback_sent#index', as: :feedback_sent
    get 'certified_company_unavailable', to: 'certified_company_unavailable#index', as: :certified_company_unavailable
    get 'further_information', to: 'further_information#index', as: :further_information
    post 'further_information', to: 'further_information#submit', as: :further_information_submit
    post 'further_information_cancel', to: 'further_information#cancel', as: :further_information_cancel
    post 'further_information_null_attribute', to: 'further_information#submit_null_attribute', as: :further_information_null_attribute_submit

    constraints route_a_and_report_to_piwik do
      get 'select_phone', to: 'select_phone#index', as: :select_phone
    end

    constraints route_b_and_report_to_piwik do
      get 'select_phone', to: 'select_phone_variant#index', as: :select_phone
    end

    constraints route_a do
      post 'select_phone', to: 'select_phone#select_phone', as: :select_phone_submit

      get 'choose_a_certified_company', to: 'choose_a_certified_company#index', as: :choose_a_certified_company
      post 'choose_a_certified_company', to: 'choose_a_certified_company#select_idp', as: :choose_a_certified_company_submit
    end

    constraints route_b do
      post 'select_phone', to: 'select_phone_variant#select_phone', as: :select_phone_submit

      get 'choose_a_certified_company', to: 'choose_a_certified_company_variant#index', as: :choose_a_certified_company
      post 'choose_a_certified_company', to: 'choose_a_certified_company_variant#select_idp', as: :choose_a_certified_company_submit
    end
  end

  put 'redirect-to-idp-warning', to: 'redirect_to_idp_warning#continue_ajax', as: :redirect_to_idp_warning_submit_ajax
  put 'select-idp', to: 'sign_in#select_idp_ajax', as: :select_idp_submit_ajax
  get 'service-status', to: 'service_status#index', as: :service_status
  get '/assets2/fp.gif', to: proc { |_| [200, {}, ['OK']] }
  get '/SAML2/metadata/sp', to: 'metadata#service_providers', as: :service_provider_metadata
  get '/SAML2/metadata/idp', to: 'metadata#identity_providers', as: :identity_provider_metadata
  get '/humans.txt', to: 'static#humanstxt'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
