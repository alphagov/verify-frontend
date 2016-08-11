class AuthnRequestController < SamlController
  protect_from_forgery except: :rp_request
  skip_before_action :validate_session

  def rp_request
    reset_session
    response = SESSION_PROXY.create_session(params['SAMLRequest'], params['RelayState'])
    set_secure_cookie(CookieNames::SESSION_ID_COOKIE_NAME, response.session_id)
    set_secure_cookie(CookieNames::SECURE_COOKIE_NAME, response.secure_cookie)
    set_current_transaction_simple_id(response.transaction_simple_id)
    set_session_start_time!

    if params['journey_hint'].present?
      redirect_to confirm_your_identity_path
    else
      redirect_to start_path
    end
  end

private

  def set_session_start_time!
    session[:start_time] = DateTime.now.to_i * 1000
  end

  def set_current_transaction_simple_id(simple_id)
    session[:transaction_simple_id] = simple_id
  end
end
