class SamlController < ApplicationController
  protect_from_forgery except: :request_post
  skip_before_action :validate_cookies

  def request_post
    reset_session
    response = authn_request_proxy.create_session(params['SAMLRequest'], params['RelayState'])

    set_secure_cookie(CookieNames::SESSION_STARTED_TIME_COOKIE_NAME, response.session_start_time)
    set_secure_cookie(CookieNames::SESSION_ID_COOKIE_NAME, response.session_id)
    set_secure_cookie(CookieNames::SECURE_COOKIE_NAME, response.secure_cookie)
    session[:transaction_simple_id] = response.transaction_simple_id

    if params['journey_hint'].present?
      redirect_to confirm_your_identity_path
    else
      redirect_to start_path
    end
  end

private

  def authn_request_proxy
    SESSION_PROXY
  end
end
