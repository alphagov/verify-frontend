Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  post 'SAML2/SSO' => 'saml#request_post'
  get 'redirect-to-idp' => 'redirect_to_idp#index', as: :redirect_to_idp

  match "/404", to: "errors#page_not_found", via: :all

  if %w(test development).include? Rails.env
    mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
    get 'test-saml' => 'test_saml#index'
    post 'test-idp-request-endpoint' => 'test_saml#idp_request'
  end

  localized do
    get 'start', to: 'start#index', as: :start
    post 'start', to: 'start#request_post', as: :start
    get 'sign_in', to: 'sign_in#index', as: :sign_in
    post 'sign_in', to: 'sign_in#select_idp', as: :sign_in
    get 'about', to: 'about#index', as: :about
    get 'about_certified_companies', to: 'about#certified_companies', as: :about_certified_companies
    get 'about_identity_accounts', to: 'about#identity_accounts', as: :about_identity_accounts
    get 'about_choosing_a_company', to: 'about#choosing_a_company', as: :about_choosing_a_company
    get 'select_documents', to: 'select_documents#index', as: :select_documents
    post 'select_documents', to: 'select_documents#select_documents', as: :select_documents_submit
    get 'select_phone', to: 'select_phone#index', as: :select_phone
    post 'select_phone', to: 'select_phone#select_phone', as: :select_phone_submit
    get 'no_mobile_phone', to: 'no_mobile_phone#index', as: :no_mobile_phone
    get 'will_it_work_for_me', to: 'will_it_work_for_me#index', as: :will_it_work_for_me
    post 'will_it_work_for_me', to: 'will_it_work_for_me#will_it_work_for_me', as: :will_it_work_for_me_submit
    get 'may_not_work_if_you_live_overseas', to: 'may_not_work_if_you_live_overseas#index', as: :may_not_work_if_you_live_overseas
    get 'why_might_this_not_work_for_me', to: 'why_might_this_not_work_for_me#index', as: :why_might_this_not_work_for_me
    get 'will_not_work_without_uk_address', to: 'will_not_work_without_uk_address#index', as: :will_not_work_without_uk_address
  end

  get '/redirect-to-service/error', to: redirect("#{API_HOST}/redirect-to-service/error")

  put 'select-idp', to: 'select_idp#select_idp', as: :select_idp
  get 'service-status', to: 'service_status#index', as: :service_status

  if Rails.env == 'development'
    get 'confirm-your-identity', to: redirect("#{API_HOST}/confirm-your-identity"), as: :confirm_your_identity
    get 'feedback', to: redirect("#{API_HOST}/feedback")
    get 'privacy-notice', to: redirect("#{API_HOST}/privacy-notice"), as: :privacy_notice
    get 'cookies', to: redirect("#{API_HOST}/cookies"), as: :cookies
    get 'forgot-company', to: redirect("#{API_HOST}/forgot-company"), as: :forgot_company
    get 'unlikely-to-verify', to: redirect("#{API_HOST}/unlikely-to-verify"), as: :unlikely_to_verify
    get 'choose-a-certified-company', to: redirect { |_, request| "#{API_HOST}/choose-a-certified-company?#{request.query_string}" }, as: :choose_a_certified_company
    get '/assets2/fp.gif', :to => proc {|env| [200, {}, ['OK']] }
  else
    get 'confirm-your-identity', to: 'confirm_your_identity#index', as: :confirm_your_identity
    get 'feedback', to: 'feedback#index', as: :feedback
    get 'privacy-notice', to: 'privacy_notice#index', as: :privacy_notice
    get 'cookies', to: 'cookies#index', as: :cookies
    get 'forgot-company', to: 'forgot_company#index', as: :forgot_company
    get 'unlikely-to-verify', to: 'unlikely_to_verify#index', as: :unlikely_to_verify
    get 'choose-a-certified-company', to: 'choose_a_certified_company#index', as: :choose_a_certified_company
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
