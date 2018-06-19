require 'ab_test/ab_test'

class AuthnRequestController < SamlController
  protect_from_forgery except: :rp_request
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def rp_request
    create_session

    # HUB-113: Temporarily disabling to allow the perf team to analyze the data
    # session[:new_visit] = true

    AbTest.set_or_update_ab_test_cookie(current_transaction_simple_id, cookies)


    journey_hint = params['journey_hint'].present? ? params['journey_hint'] : 'unspecified'
    follow_journey_hint journey_hint
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

  def follow_journey_hint(hint)
    case hint
    when 'registration'
      redirect_to begin_registration_path
    when 'uk_idp_sign_in'
      redirect_to begin_sign_in_path
    when 'eidas_sign_in'
      raise StandardError, 'Users session does not support eIDAS journeys' unless session[:transaction_supports_eidas]
      redirect_to choose_a_country_path
    when 'submission_confirmation'
      redirect_to confirm_your_identity_path
    when 'unspecified'
      if session[:transaction_supports_eidas]
        redirect_to prove_identity_path
      else
        redirect_to start_path
      end
    else
      # TODO: we actually want this to be the same as the unspecified case.
      # However, the old code allowed RPs to submit any other value they liked
      # and get the non-repudiation flow. Hence, we cannot remove this until we've
      # verified what everyone is sending to activate that flow.
      logger.info "journey_hint value: #{hint}"
      redirect_to confirm_your_identity_path
    end
  end
end
