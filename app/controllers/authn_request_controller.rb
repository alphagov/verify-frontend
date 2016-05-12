class AuthnRequestController < ApplicationController
  protect_from_forgery except: :rp_request
  skip_before_action :validate_cookies

  def set_locale
    I18n.locale = locale_from_journey_hint
  end

  def rp_request
    reset_session
    response = SESSION_PROXY.create_session(params['SAMLRequest'], params['RelayState'])

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
end
