require "webmock/rspec"

def set_session_and_cookies_with_loa(loa_requested, transaction_simple_id = "test-rp", journey_type: JourneyType::SIGN_IN)
  session[:requested_loa] = loa_requested
  session[:verify_session_id] = "my-session-id-cookie"
  session[:transaction_simple_id] = transaction_simple_id
  session[:transaction_entity_id] = "http://www.test-rp.gov.uk/SAML2/MD"
  session[:transaction_homepage] = "www.example.com"
  session[:start_time] = Time.now.to_i * 1000
  session[:journey_type] = journey_type
  cookies[CookieNames::SESSION_COOKIE_NAME] = "my-session-cookie"
  cookies[CookieNames::SESSION_ID_COOKIE_NAME] = "my-session-id-cookie"
end

def set_session_and_cookies_with_loa_and_variant(loa_request, experiment, variant, transaction_simple_id = "test-rp")
  set_session_and_cookies_with_loa(loa_request, transaction_simple_id)
  cookies[CookieNames::AB_TEST] = "{\"#{experiment}\": \"#{variant}\"}"
end

def set_selected_idp(selected_idp)
  session[:selected_provider] = SelectedProviderData.new(selected_idp)
end

def set_transaction(transaction_id)
  session[:transaction_simple_id] = transaction_id
end

def set_journey_type(journey_type)
  session[:journey_type] = journey_type
end
