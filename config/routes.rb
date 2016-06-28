Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
    get 'select_phone', to: 'select_phone#index', as: :select_phone
    post 'select_phone', to: 'select_phone#select_phone', as: :select_phone_submit
    get 'no_mobile_phone', to: 'select_phone#no_mobile_phone', as: :no_mobile_phone
    get 'will_it_work_for_me', to: 'will_it_work_for_me#index', as: :will_it_work_for_me
    post 'will_it_work_for_me', to: 'will_it_work_for_me#will_it_work_for_me', as: :will_it_work_for_me_submit
    get 'why_might_this_not_work_for_me', to: 'will_it_work_for_me#why_might_this_not_work_for_me', as: :why_might_this_not_work_for_me
    get 'may_not_work_if_you_live_overseas', to: 'will_it_work_for_me#may_not_work_if_you_live_overseas', as: :may_not_work_if_you_live_overseas
    get 'will_not_work_without_uk_address', to: 'will_it_work_for_me#will_not_work_without_uk_address', as: :will_not_work_without_uk_address
    get 'choose_a_certified_company', to: 'choose_a_certified_company#index', as: :choose_a_certified_company
    get 'choose_a_certified_company_about', to: 'choose_a_certified_company#about', as: :choose_a_certified_company_about
    post 'choose_a_certified_company', to: 'choose_a_certified_company#select_idp', as: :choose_a_certified_company_submit
    get 'why_companies', to: 'why_companies#index', as: :why_companies
    get 'redirect_to_idp_warning', to: 'redirect_to_idp_warning#index', as: :redirect_to_idp_warning
    post 'redirect_to_idp_warning', to: 'redirect_to_idp_warning#continue', as: :redirect_to_idp_warning_submit
    get 'privacy_notice', to: 'static#privacy_notice', as: :privacy_notice
    get 'cookies', to: 'static#cookies', as: :cookies
    get 'confirm_your_identity', to: 'confirm_your_identity#index', as: :confirm_your_identity
    get 'confirmation', to: 'confirmation#index', as: :confirmation
    get 'failed_registration', to: 'failed_registration#index', as: :failed_registration
    get 'failed_sign_in', to: 'failed_sign_in#index', as: :failed_sign_in
    get 'other_ways_to_access_service', to: 'other_ways_to_access_service#index', as: :other_ways_to_access_service
    get 'forgot_company', to: 'static#forgot_company', as: :forgot_company
    get 'response_processing', to: 'response_processing#index', as: :response_processing
    get 'redirect_to_idp', to: 'redirect_to_idp#index', as: :redirect_to_idp
    get 'redirect_to_service_signing_in' => 'redirect_to_service#signing_in', as: :redirect_to_service_signing_in
    get 'redirect_to_service_start_again' => 'redirect_to_service#start_again', as: :redirect_to_service_start_again
    get 'redirect_to_service_error' => 'redirect_to_service#error', as: :redirect_to_service_error
    get 'feedback', to: 'feedback#index', as: :feedback
    post 'feedback', to: 'feedback#submit', as: :feedback_submit
  end

  put 'redirect-to-idp-warning', to: 'redirect_to_idp_warning#continue_ajax', as: :redirect_to_idp_warning_submit_ajax
  put 'select-idp', to: 'sign_in#select_idp_ajax', as: :select_idp_submit_ajax
  get 'service-status', to: 'service_status#index', as: :service_status
  get '/assets2/fp.gif', to: proc { |_| [200, {}, ['OK']] }


  if Rails.env == 'development'
    get 'further-information', to: redirect("#{API_HOST}/further-information"), as: :further_information
    get 'feedback/feedback-sent', to: redirect("#{API_HOST}/feedback/feedback-sent"), as: :feedback_sent
  else
    get 'further-information', to: proc { |_| [200, {}, ['OK']] }, as: :further_information
    get 'feedback/feedback-sent', to: proc { |_| [200, {}, ['OK']] }, as: :feedback_sent
  end

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
