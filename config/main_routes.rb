def add_routes(routes_name)
  instance_eval(File.read(Rails.root.join("config/#{routes_name}.rb")))
end

get "sign_in", to: "sign_in#index", as: :sign_in
post "sign_in", to: "sign_in#select_idp", as: :sign_in_submit
get "begin_sign_in", to: "start#sign_in", as: :begin_sign_in

# HUB-595 short hub 2019 q3 A/B test (short_hub_2019_q3)
# SHORT_HUB_2019_Q3 = "short_hub_2019_q3".freeze
# short_hub_v3 = AbTestConstraint.configure(ab_test_name: SHORT_HUB_2019_Q3, experiment_loa: "LEVEL_2")

constraints IsLoa1 do
  get "prove_identity", to: "prove_identity#index", as: :prove_identity
  get "prove_identity_retry", to: "prove_identity#retry_eidas_journey", as: :prove_identity_retry
  get "start", to: "start#index", as: :start
  post "start", to: "start#request_post", as: :start
  get "begin_registration", to: "start#register", as: :begin_registration
  get "choose_a_certified_company", to: "choose_a_certified_company_loa1#index", as: :choose_a_certified_company
  post "choose_a_certified_company", to: "choose_a_certified_company_loa1#select_idp", as: :choose_a_certified_company_submit
  get "choose_a_certified_company/:company", to: "choose_a_certified_company_loa1#about", as: :choose_a_certified_company_about
  get "why_companies", to: "why_companies_loa1#index", as: :why_companies
  get "failed_registration", to: "failed_registration_loa1#index", as: :failed_registration
  get "cancelled_registration", to: "cancelled_registration_loa1#index", as: :cancelled_registration
  get "redirect_to_idp_question", to: "redirect_to_idp_question_loa1#index", as: :redirect_to_idp_question
  post "redirect_to_idp_question", to: "redirect_to_idp_question_loa1#continue", as: :redirect_to_idp_question_submit
  post "redirect_to_idp_warning", to: "redirect_to_idp_warning#continue", as: :redirect_to_idp_warning_submit
  get "redirect_to_idp_warning", to: "redirect_to_idp_warning#index", as: :redirect_to_idp_warning
  get "idp_wont_work_for_you_one_doc", to: "redirect_to_idp_question_loa1#idp_wont_work_for_you", as: :idp_wont_work_for_you_one_doc
  get "confirmation", to: "confirmation_loa1#matching_journey", as: :confirmation
  get "about", to: "about_loa1#index", as: :about
  get "about_certified_companies", to: "about_loa1#certified_companies", as: :about_certified_companies
  get "about_identity_accounts", to: "about_loa1#identity_accounts", as: :about_identity_accounts
  get "about_choosing_a_company", to: "about_loa1#choosing_a_company", as: :about_choosing_a_company
  get "confirmation_non_matching_journey", to: "confirmation_loa1#non_matching_journey", as: :confirmation_non_matching_journey
end

constraints IsLoa2 do
  get "prove_identity", to: "prove_identity#index", as: :prove_identity
  get "prove_identity_retry", to: "prove_identity#retry_eidas_journey", as: :prove_identity_retry
  get "prove_identity_ignore_hint", to: "prove_identity#ignore_hint", as: :prove_identity_ignore_hint
  get "start", to: "start#index", as: :start
  post "start", to: "start#request_post", as: :start
  get "begin_registration", to: "start#register", as: :begin_registration
  get "why_might_this_not_work_for_me", to: "will_it_work_for_me#why_might_this_not_work_for_me", as: :why_might_this_not_work_for_me
  get "may_not_work_if_you_live_overseas", to: "will_it_work_for_me#may_not_work_if_you_live_overseas", as: :may_not_work_if_you_live_overseas
  get "will_not_work_without_uk_address", to: "will_it_work_for_me#will_not_work_without_uk_address", as: :will_not_work_without_uk_address
  get "other_identity_documents", to: "other_identity_documents#index", as: :other_identity_documents
  post "other_identity_documents", to: "other_identity_documents#select_other_documents", as: :other_identity_documents_submit
  get "select_phone", to: "select_phone#index", as: :select_phone
  post "select_phone", to: "select_phone#select_phone", as: :select_phone_submit
  get "verify_will_not_work_for_you", to: "select_phone#verify_will_not_work_for_you", as: :verify_will_not_work_for_you
  get "why_companies", to: "why_companies_loa2#index", as: :why_companies
  get "cancelled_registration", to: "cancelled_registration_loa2#index", as: :cancelled_registration
  post "redirect_to_idp_warning", to: "redirect_to_idp_warning#continue", as: :redirect_to_idp_warning_submit
  get "redirect_to_idp_warning", to: "redirect_to_idp_warning#index", as: :redirect_to_idp_warning
  get "redirect_to_idp_question", to: "redirect_to_idp_question_loa2#index", as: :redirect_to_idp_question
  post "redirect_to_idp_question", to: "redirect_to_idp_question_loa2#continue", as: :redirect_to_idp_question_submit
  get "idp_wont_work_for_you_one_doc", to: "redirect_to_idp_question_loa2#idp_wont_work_for_you", as: :idp_wont_work_for_you_one_doc
  get "confirmation", to: "confirmation_loa2#matching_journey", as: :confirmation
  get "confirmation_non_matching_journey", to: "confirmation_loa2#non_matching_journey", as: :confirmation_non_matching_journey
end

get "start_ignore_hint", to: "start#ignore_hint", as: :start_ignore_hint
get "accessibility", to: "static#accessibility", as: :accessibility
get "privacy_notice", to: "static#privacy_notice", as: :privacy_notice
get "verify_services", to: "static#verify_services", as: :verify_services
get "proxy_node_error", to: "errors#proxy_node_error", as: :proxy_node_error
get "cookies", to: "static#cookies", as: :cookies
get "confirm_your_identity", to: "confirm_your_identity#index", as: :confirm_your_identity
get "choose_a_country", to: "choose_a_country#choose_a_country", as: :choose_a_country
post "redirect_to_country", to: "redirect_to_country#choose_a_country_submit", as: :choose_a_country_submit
get "failed_uplift", to: "failed_uplift#index", as: :failed_uplift
get "failed_sign_in", to: "failed_sign_in#idp", as: :failed_sign_in
get "failed_country_sign_in", to: "failed_sign_in#country", as: :failed_country_sign_in
get "other_ways_to_access_service", to: "other_ways_to_access_service#index", as: :other_ways_to_access_service
get "other_ways_after_eidas", to: "other_ways_to_access_service#after_eidas", as: :other_ways_after_eidas
get "forgot_company", to: "static#forgot_company", as: :forgot_company
get "response_processing", to: "response_processing#index", as: :response_processing
get "redirect_to_idp_register", to: "redirect_to_idp#register", as: :redirect_to_idp_register
get "redirect_to_idp_sign_in", to: "redirect_to_idp#sign_in", as: :redirect_to_idp_sign_in
get "redirect_to_idp_sign_in_with_last_successful_idp", to: "redirect_to_idp#sign_in_with_last_successful_idp", as: :redirect_to_idp_sign_in_with_last_successful_idp
get "redirect_to_idp_resume", to: "redirect_to_idp#resume", as: :redirect_to_idp_resume
get "redirect_to_service_signing_in" => "redirect_to_service#signing_in", as: :redirect_to_service_signing_in
get "redirect_to_service_start_again" => "redirect_to_service#start_again", as: :redirect_to_service_start_again
get "redirect_to_service_error" => "redirect_to_service#error", as: :redirect_to_service_error
get "redirect_to_country" => "choose_a_country#choose_a_country", as: :redirect_to_country
get "feedback_landing", to: "feedback_landing#index", as: :feedback_landing
get "feedback", to: "feedback#index", as: :feedback
post "feedback", to: "feedback#submit", as: :feedback_submit
get "feedback_sent", to: "feedback_sent#index", as: :feedback_sent
get "further_information", to: "further_information#index", as: :further_information
get "further_information_timeout", to: "further_information#timeout", as: :further_information_timeout
post "further_information", to: "further_information#submit", as: :further_information_submit
post "further_information_cancel", to: "further_information#cancel", as: :further_information_cancel
post "further_information_null_attribute", to: "further_information#submit_null_attribute", as: :further_information_null_attribute_submit
get "no_idps_available", to: "no_idps_available#index", as: :no_idps_available
get "cancelled_registration", to: "cancelled_registration#index", as: :cancelled_registration
get "paused_registration", to: "paused_registration#index", as: :paused_registration
get "paused_registration_resume_link", to: "paused_registration#from_resume_link", as: :paused_registration_resume_link
get "resume_registration", to: "paused_registration#resume", as: :resume_registration
post "resume_registration", to: "paused_registration#resume_with_idp", as: :resume_registration_submit
get "completed_registration", to: "completed_registration#index", as: :completed_registration

if SINGLE_IDP_FEATURE
  get "redirect_to_single_idp", to: "redirect_to_idp#single_idp", as: :redirect_to_single_idp
  get "continue_to_your_idp", to: "single_idp_journey#continue_to_your_idp", as: :continue_to_your_idp
  post "continue_to_your_idp", to: "single_idp_journey#continue"
  get "single_idp_start_page", to: "single_idp_journey#rp_start_page", as: :single_idp_start_page
end

# HUB-595: implement control A route
# constraints short_hub_v3.use(alternative: "control_a") do; end
=begin
  get "about_certified_companies", to: "about_loa2#certified_companies", as: :about_certified_companies
  get "about_identity_accounts", to: "about_loa2#identity_accounts", as: :about_identity_accounts
  get "about", to: "about_loa2#index", as: :about
  get "about_choosing_a_company", to: "about_loa2#choosing_a_company", as: :about_choosing_a_company
  get "will_it_work_for_me", to: "will_it_work_for_me#index", as: :will_it_work_for_me
  post "will_it_work_for_me", to: "will_it_work_for_me#will_it_work_for_me", as: :will_it_work_for_me_submit
  get "select_documents", to: "select_documents#index", as: :select_documents
  get "select_documents_none", to: "select_documents#no_documents", as: :select_documents_no_documents
  post "select_documents", to: "select_documents#select_documents", as: :select_documents_submit

  get "select_phone", to: "select_phone#index", as: :select_phone
  post "select_phone", to: "select_phone#select_phone", as: :select_phone_submit
  get "verify_will_not_work_for_you", to: "select_phone#verify_will_not_work_for_you", as: :verify_will_not_work_for_you
  get "failed_registration", to: "failed_registration_loa2#index", as: :failed_registration
  get "choose_a_certified_company", to: "choose_a_certified_company_loa2#index", as: :choose_a_certified_company
  get "choose_a_certified_company/:company", to: "choose_a_certified_company_loa2#about", as: :choose_a_certified_company_about
  post "choose_a_certified_company", to: "choose_a_certified_company_loa2#select_idp", as: :choose_a_certified_company_submit
=end
# HUB-595: implement appropriate variant C routes
# constraints short_hub_v3.use(alternative: "variant_c_2_idp_short_hub") do; end
get "about", to: "about_loa2#index", as: :about
get "about_choosing_a_company", to: "about_loa2#choosing_a_company", as: :about_choosing_a_company
get "will_it_work_for_me", to: "will_it_work_for_me#index", as: :will_it_work_for_me
post "will_it_work_for_me", to: "will_it_work_for_me#will_it_work_for_me", as: :will_it_work_for_me_submit
get "select_documents", to: "select_documents_variant_c#index", as: :select_documents
get "select_documents_none", to: "select_documents_variant_c#no_documents", as: :select_documents_no_documents
post "select_documents", to: "select_documents_variant_c#select_documents", as: :select_documents_submit
get "select_documents_advice", to: "select_documents_variant_c#advice", as: :select_documents_advice
get "prove_your_identity_another_way", to: "select_documents_variant_c#prove_your_identity_another_way", as: :prove_your_identity_another_way
get "choose_a_certified_company", to: "choose_a_certified_company_loa2_variant_c#index", as: :choose_a_certified_company
get "choose_a_certified_company/:company", to: "choose_a_certified_company_loa2_variant_c#about", as: :choose_a_certified_company_about
post "choose_a_certified_company", to: "choose_a_certified_company_loa2_variant_c#select_idp", as: :choose_a_certified_company_submit
get "failed_registration", to: "failed_registration_loa2#index", as: :failed_registration
