require 'ab_test/ab_test'

class AuthnRequestController < SamlController
  include JourneyHinting
  protect_from_forgery except: :rp_request
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def rp_request
    return if raise_error_if_params_invalid

    session_journey_hint_value = session.fetch(:journey_hint, nil)
    session_journey_hint_rp = session.fetch(:journey_hint_rp, nil)
    create_session

    # HUB-113: Temporarily disabling to allow the perf team to analyze the data
    # session[:new_visit] = true

    AbTest.set_or_update_ab_test_cookie(current_transaction_simple_id, cookies)

    redirect_for_journey_hint preferred_journey_hint(session_journey_hint_value, session_journey_hint_rp)
  end

private

  def create_session
    reset_session
    store_rp_request_data
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

  def preferred_journey_hint(session_journey_hint, session_journey_hint_rp)
    default_value = session[:transaction_simple_id] == session_journey_hint_rp ? session_journey_hint : nil
    params.fetch('journey_hint', default_value)
  end

  def redirect_for_journey_hint(hint)
    if !cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY].nil? && SINGLE_IDP_FEATURE
      redirect_to continue_to_your_idp_path
    elsif (is_last_status?(PENDING_STATUS) || resume_link?) && hint != 'submission_confirmation'
      redirect_to resume_registration_path
    else
      case hint
      when 'uk_idp_start'
        flash[:journey_hint] = hint
        redirect_to start_path
      when 'registration'
        flash[:journey_hint] = hint
        redirect_to start_path # Change temporarily, original value = begin_registration_path
      when 'uk_idp_sign_in'
        flash[:journey_hint] = hint
        redirect_to start_path # Change temporarily, original value = begin_sign_in_path
      when 'eidas_sign_in'
        do_eidas_sign_in_redirect
      when 'submission_confirmation'
        redirect_to confirm_your_identity_path
      else
        logger.info "Unrecognised journey_hint value: #{hint}" unless hint.nil? || hint.eql?('unspecified')
        do_default_redirect
      end
    end
  end

  def do_eidas_sign_in_redirect
    return redirect_to start_path unless session[:transaction_supports_eidas]

    redirect_to choose_a_country_path
  end

  def do_default_redirect
    return redirect_to start_path unless session[:transaction_supports_eidas]

    redirect_to prove_identity_path
  end

  def store_rp_request_data
    RequestStore.store[:rp_referer] = request.referer
    RequestStore.store[:rp_saml_request] = params.fetch('SAMLRequest', nil)
    RequestStore.store[:rp_relay_state] = params.fetch('RelayState', nil)
  end

  def raise_error_if_params_invalid
    something_went_wrong_warn("Missing/empty SAML message from #{request.referer}", :bad_request) if params['SAMLRequest'].blank?
  end
end
