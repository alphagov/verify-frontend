require 'webmock/rspec'

def set_session_and_cookies_with_loa(loa_requested, identity_providers = [{ 'simple_id' => 'stub-idp-one', 'entity_id' => 'http://idcorp.com' }])
  session[:requested_loa] = loa_requested
  session[:verify_session_id] = 'my-session-id-cookie'
  session[:transaction_simple_id] = 'test-rp'
  session[:identity_providers] = identity_providers
  session[:start_time] = DateTime.now.to_i * 1000
  cookies[CookieNames::SESSION_COOKIE_NAME] = 'my-session-cookie'
  cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'my-session-id-cookie'
end

def stub_session
  session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-loa1', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
  session[:selected_idp_was_recommended] = true
  session[:transaction_simple_id] = 'test-rp'
end
