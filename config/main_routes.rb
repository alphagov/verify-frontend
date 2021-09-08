def add_routes(routes_name)
  instance_eval(File.read(Rails.root.join("config/#{routes_name}.rb")))
end

get "sign_in", to: "sign_in#index", as: :sign_in
get "sign_in_warning", to: "sign_in#warn_idp_disconnecting", as: :sign_in_warning
post "sign_in_warning", to: "sign_in#warn_idp_disconnecting", as: :sign_in_warning
post "sign_in_confirm", to: "sign_in#confirm_idp", as: :sign_in_confirm
post "sign_in", to: "sign_in#select_idp", as: :sign_in_submit
get "begin_sign_in", to: "start#sign_in", as: :begin_sign_in

constraints IsLoa1 do
  get "prove_identity", to: "prove_identity#index", as: :prove_identity
  get "start", to: "start#index", as: :start
  post "start", to: "start#request_post", as: :start
  get "begin_registration", to: "start#register", as: :begin_registration
  get "choose_a_certified_company", to: "choose_a_certified_company_loa1#index", as: :choose_a_certified_company
  post "choose_a_certified_company", to: "choose_a_certified_company_loa1#select_idp", as: :choose_a_certified_company_submit
  get "choose_a_certified_company/:company", to: "choose_a_certified_company_loa1#about", as: :choose_a_certified_company_about
end

constraints IsLoa2 do
  get "prove_identity", to: "prove_identity#index", as: :prove_identity
  get "prove_identity_ignore_hint", to: "prove_identity#ignore_hint", as: :prove_identity_ignore_hint
  get "start", to: "start#index", as: :start
  post "start", to: "start#request_post", as: :start
  get "begin_registration", to: "start#register", as: :begin_registration
  get "choose_a_certified_company", to: "choose_a_certified_company_loa2#index", as: :choose_a_certified_company
  get "choose_a_certified_company/:company", to: "choose_a_certified_company_loa2#about", as: :choose_a_certified_company_about
  post "choose_a_certified_company", to: "choose_a_certified_company_loa2#select_idp", as: :choose_a_certified_company_submit
  get "will_it_work_for_me", to: "will_it_work_for_me#index", as: :will_it_work_for_me
  post "will_it_work_for_me", to: "will_it_work_for_me#will_it_work_for_me", as: :will_it_work_for_me_submit
  get "about_documents", to: "about#about_documents", as: :about_documents
  get "prove_your_identity_another_way", to: "about#prove_your_identity_another_way", as: :prove_your_identity_another_way
  get "select_documents", to: "select_documents#index", as: :select_documents
  post "select_documents", to: "select_documents#select_documents", as: :select_documents_submit
  get "select_documents_advice", to: "select_documents#advice", as: :select_documents_advice
  get "why_might_this_not_work_for_me", to: "will_it_work_for_me#why_might_this_not_work_for_me", as: :why_might_this_not_work_for_me
  get "may_not_work_if_you_live_overseas", to: "will_it_work_for_me#may_not_work_if_you_live_overseas", as: :may_not_work_if_you_live_overseas
  get "will_not_work_without_uk_address", to: "will_it_work_for_me#will_not_work_without_uk_address", as: :will_not_work_without_uk_address
end

get "start_ignore_hint", to: "start#ignore_hint", as: :start_ignore_hint
get "accessibility", to: "static#accessibility", as: :accessibility
get "privacy_notice", to: "static#privacy_notice", as: :privacy_notice
get "verify_services", to: "static#verify_services", as: :verify_services
get "cookies", to: "static#cookies", as: :cookies
get "about", to: "about#about_verify", as: :about
get "about_choosing_a_company", to: "about#about_choosing_a_company", as: :about_choosing_a_company
get "confirm_your_identity", to: "confirm_your_identity#index", as: :confirm_your_identity
get "failed_uplift", to: "failed_uplift#index", as: :failed_uplift
get "failed_sign_in", to: "failed_sign_in#idp", as: :failed_sign_in
get "other_ways_to_access_service", to: "other_ways_to_access_service#index", as: :other_ways_to_access_service
get "forgot_company", to: "static#forgot_company", as: :forgot_company
get "response_processing", to: "response_processing#index", as: :response_processing
get "redirect_to_idp_register", to: "redirect_to_idp#register", as: :redirect_to_idp_register
get "redirect_to_idp_sign_in", to: "redirect_to_idp#sign_in", as: :redirect_to_idp_sign_in
get "redirect_to_idp_sign_in_with_last_successful_idp", to: "redirect_to_idp#sign_in_with_last_successful_idp", as: :redirect_to_idp_sign_in_with_last_successful_idp
get "redirect_to_idp_resume", to: "redirect_to_idp#resume", as: :redirect_to_idp_resume
get "redirect_to_service_signing_in", to: "redirect_to_service#signing_in", as: :redirect_to_service_signing_in
get "redirect_to_service_start_again", to: "redirect_to_service#start_again", as: :redirect_to_service_start_again
get "redirect_to_service_error", to: "redirect_to_service#error", as: :redirect_to_service_error
get "feedback_landing", to: "feedback_landing#index", as: :feedback_landing
get "confirmation", to: "confirmation#matching_journey", as: :confirmation
get "confirmation_non_matching_journey", to: "confirmation#non_matching_journey", as: :confirmation_non_matching_journey
get "failed_registration", to: "failed_registration#index", as: :failed_registration
get "feedback", to: "feedback#index", as: :feedback
post "feedback", to: "feedback#submit", as: :feedback_submit
get "feedback_sent", to: "feedback_sent#index", as: :feedback_sent
get "further_information", to: "further_information#index", as: :further_information
get "further_information_timeout", to: "further_information#timeout", as: :further_information_timeout
post "further_information", to: "further_information#submit", as: :further_information_submit
post "further_information_cancel", to: "further_information#cancel", as: :further_information_cancel
post "further_information_null_attribute", to: "further_information#submit_null_attribute", as: :further_information_null_attribute_submit
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
