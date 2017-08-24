class AuthnRequestController < SamlController
  protect_from_forgery except: :rp_request
  skip_before_action :validate_session

  def rp_request
    reset_session
    response = SESSION_PROXY.create_session(params['SAMLRequest'], params['RelayState'])
    set_secure_cookie(CookieNames::SESSION_ID_COOKIE_NAME, response.session_id)
    session[:verify_session_id] = response.session_id
    session[:transaction_supports_eidas] = response.transaction_supports_eidas
    set_current_transaction_simple_id(response.transaction_simple_id)
    set_requested_loa(response.levels_of_assurance)
    set_session_start_time!

    if params['journey_hint'].present?
      redirect_to confirm_your_identity_path
    elsif params['eidas_journey'].present?
      raise StandardError, 'Users session does not support eIDAS journeys' unless response.transaction_supports_eidas
      redirect_to choose_a_country_path
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

  def set_requested_loa(levels_of_assurance)
    requested_loa = levels_of_assurance.first
    session[:requested_loa] = requested_loa
  end
end
