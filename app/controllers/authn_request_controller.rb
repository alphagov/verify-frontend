require 'ab_test/ab_test'

class AuthnRequestController < SamlController
  protect_from_forgery except: :rp_request
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def rp_request
    create_session

    AbTest.set_or_update_ab_test_cookie(current_transaction_simple_id, cookies)

    if params['journey_hint'].present?
      follow_journey_hint
    elsif params['eidas_journey'].present?
      raise StandardError, 'Users session does not support eIDAS journeys' unless session[:transaction_supports_eidas]
      redirect_to choose_a_country_path
    else
      redirect_to start_path
    end
  end

private

  def create_session
    reset_session

    session_id = SAML_PROXY_API.create_session(params['SAMLRequest'], params['RelayState'])
    set_secure_cookie(CookieNames::SESSION_ID_COOKIE_NAME, session_id)
    set_session_id(session_id)
    sign_in_process_details = POLICY_PROXY.get_sign_in_process_details(session_id)
    set_transaction_supports_eidas(sign_in_process_details.transaction_supports_eidas)
    set_transaction_entity_id(sign_in_process_details.transaction_entity_id)
    transaction_data = CONFIG_PROXY.get_transaction_details(sign_in_process_details.transaction_entity_id)
    set_transaction_simple_id(transaction_data.simple_id)
    set_requested_loa(transaction_data.levels_of_assurance)
    set_transaction_homepage(transaction_data.transaction_homepage)

    set_session_start_time!
  end

  def set_session_start_time!
    session[:start_time] = Time.now.to_i * 1000
  end

  def set_session_id(session_id)
    session[:verify_session_id] = session_id
  end

  def set_transaction_supports_eidas(transaction_supports_eidas)
    session[:transaction_supports_eidas] = transaction_supports_eidas
  end

  def set_transaction_simple_id(simple_id)
    session[:transaction_simple_id] = simple_id
  end

  def set_transaction_entity_id(entity_id)
    session[:transaction_entity_id] = entity_id
  end

  def set_requested_loa(levels_of_assurance)
    requested_loa = levels_of_assurance.first
    session[:requested_loa] = requested_loa
  end

  def set_transaction_homepage(transaction_homepage)
    session[:transaction_homepage] = transaction_homepage
  end

  def follow_journey_hint
    if check_journey_hint('registration')
      redirect_to begin_registration_path
    elsif check_journey_hint('sign_in')
      redirect_to sign_in_path
    else
      redirect_to confirm_your_identity_path
    end
  end

  def check_journey_hint(path)
    params['journey_hint'] == path
  end
end
