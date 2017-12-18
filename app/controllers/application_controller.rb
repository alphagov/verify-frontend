require 'redirect_with_see_other'
require 'cookies/cookies'

class ApplicationController < ActionController::Base
  include DeviceType

  before_action :validate_session
  before_action :set_visitor_cookie
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :store_originating_ip
  before_action :set_piwik_custom_variables
  after_action :store_locale_in_cookie, if: -> { request.method == 'GET' }
  helper_method :transaction_taxon_list
  helper_method :transactions_list
  helper_method :loa1_transactions_list
  helper_method :loa2_transactions_list
  helper_method :public_piwik

  rescue_from StandardError, with: :something_went_wrong unless Rails.env == 'development'
  rescue_from Errors::WarningLevelError, with: :something_went_wrong_warn
  rescue_from Api::SessionError, with: :session_error
  rescue_from Api::UpstreamError, with: :something_went_wrong_warn
  rescue_from Api::SessionTimeoutError, with: :session_timeout

  prepend RedirectWithSeeOther

  def transaction_taxon_list
    TRANSACTION_TAXON_CORRELATOR.correlate(CONFIG_PROXY.transactions)
  end

  def transactions_list
    DATA_CORRELATOR.correlate(CONFIG_PROXY.transactions)
  end

  def loa1_transactions_list
    Display::Rp::TransactionFilter.new.filter_by_loa(transactions_list, 'LEVEL_1')
  end

  def loa2_transactions_list
    Display::Rp::TransactionFilter.new.filter_by_loa(transactions_list, 'LEVEL_2')
  end

  def current_transaction
    @current_transaction ||= RP_DISPLAY_REPOSITORY.fetch(current_transaction_simple_id)
  end

  def current_transaction_simple_id
    session[:transaction_simple_id]
  end

  def current_transaction_entity_id
    session[:transaction_entity_id]
  end

  def current_transaction_homepage
    session[:transaction_homepage]
  end

  def store_locale_in_cookie
    cookies.signed[CookieNames::VERIFY_LOCALE] = {
      value: I18n.locale,
      httponly: true,
      secure: Rails.configuration.x.cookies.secure
    }
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def validate_session
    validation = session_validator.validate(cookies, session)
    unless validation.ok?
      logger.info(validation.message)
      render_error(validation.type, validation.status)
    end
  end

  def set_visitor_cookie
    cookies[CookieNames::PIWIK_USER_ID] = SecureRandom.hex(8) unless cookies.has_key? CookieNames::PIWIK_USER_ID
  end

  def ensure_session_eidas_supported
    txn_supports_eidas = session[:transaction_supports_eidas]
    unless txn_supports_eidas
      something_went_wrong('Transaction does not support Eidas', :forbidden)
    end
  end

  def set_secure_cookie(name, value)
    cookies[name] = {
      value: value,
      httponly: true,
      secure: Rails.configuration.x.cookies.secure
    }
  end

  def selected_answer_store
    @selected_answer_store ||= SelectedAnswerStore.new(session)
  end

  def selected_evidence
    selected_answer_store.selected_evidence
  end

  def set_journey_hint(idp_entity_id)
    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: idp_entity_id }.to_json
  end

private

  def uri_with_query(path, query_string)
    uri = URI(path)
    uri.query = query_string
    uri.to_s
  end

  def render_error(partial, status)
    set_locale
    respond_to do |format|
      format.html { render "errors/#{partial}", status: status, layout: 'application' }
      format.json { render json: {}, status: status }
    end
  end

  def render_not_found
    set_locale
    respond_to do |format|
      format.html { render 'errors/404', status: 404 }
      format.json { render json: {}, status: 404 }
    end
  end

  def session_validator
    SESSION_VALIDATOR
  end

  def public_piwik
    PUBLIC_PIWIK
  end

  def session_timeout(exception)
    logger.info(exception)
    render_error('session_timeout', :forbidden)
  end

  def session_error(exception)
    logger.warn(exception)
    render_error('session_error', :bad_request)
  end

  def something_went_wrong(exception, status = :internal_server_error)
    logger.error(exception)
    render_error('something_went_wrong', status)
  end

  def something_went_wrong_warn(exception)
    logger.warn(exception)
    render_error('something_went_wrong', :internal_server_error)
  end

  def store_originating_ip
    OriginatingIpStore.store(request)
  end

  def selected_identity_provider
    selected_idp = session[:selected_idp]
    if selected_idp.nil?
      raise(Errors::WarningLevelError, 'No selected IDP in session')
    else
      IdentityProvider.from_session(selected_idp)
    end
  end

  def current_identity_providers_for_loa
    CONFIG_PROXY.get_idp_list_for_loa(session[:transaction_entity_id], session[:requested_loa]).idps
  end

  def current_identity_providers_for_sign_in
    CONFIG_PROXY.get_idp_list_for_sign_in(session[:transaction_entity_id]).idps
  end

  def report_to_analytics(action_name)
    FEDERATION_REPORTER.report_action(current_transaction, request, action_name)
  end

  def hide_available_languages
    @hide_available_languages = true
  end

  def hide_feedback_link
    @hide_feedback_link = true
  end

  def select_viewable_idp_for_sign_in(entity_id)
    for_viewable_idp(entity_id, current_identity_providers_for_sign_in) do |decorated_idp|
      session[:selected_idp] = decorated_idp.identity_provider
      yield decorated_idp
    end
  end

  def select_viewable_idp_for_loa(entity_id)
    for_viewable_idp(entity_id, current_identity_providers_for_loa) do |decorated_idp|
      session[:selected_idp] = decorated_idp.identity_provider
      yield decorated_idp
    end
  end

  def for_viewable_idp(entity_id, identity_provider_list)
    matching_idp = identity_provider_list.detect { |idp| idp.entity_id == entity_id }
    idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if idp.viewable?
      yield idp
    else
      logger.error 'Unrecognised IdP simple id'
      render_not_found
    end
  end

  def ajax_idp_redirection_sign_in_request
    FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, session[:selected_idp_name])

    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initilization(outbound_saml_message)
    render json: idp_request
  end

  def ajax_idp_redirection_registration_request(recommended)
    report_idp_registration_to_piwik(recommended)
    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initilization(outbound_saml_message)
    render json: idp_request.to_json(methods: :hints)
  end

  def report_idp_registration_to_piwik(recommended)
    FEDERATION_REPORTER.report_idp_registration(
      current_transaction: current_transaction,
      request: request,
      idp_name: session[:selected_idp_name],
      idp_name_history: session[:selected_idp_names],
      evidence: selected_answer_store.selected_evidence,
      recommended: recommended,
      user_segments: session[:user_segments]
    )
  end

  def idp_request_initilization(outbound_saml_message)
    IdentityProviderRequest.new(
      outbound_saml_message,
      selected_identity_provider.simple_id,
      selected_answer_store.selected_answers
    )
  end

  def set_piwik_custom_variables
    @piwik_custom_variables = [
        Analytics::CustomVariable.build_for_js_client(:rp, current_transaction.analytics_description),
        Analytics::CustomVariable.build_for_js_client(:loa_requested, session[:requested_loa])
    ]
  end

  def set_device_type_evidence
    selected_answer_store.store_selected_answers('device_type', device_type)
  end
end
