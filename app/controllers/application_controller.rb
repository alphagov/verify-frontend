require 'redirect_with_see_other'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_filter :store_session_id
  before_filter :store_originating_ip
  before_action :validate_cookies
  helper_method :transactions_list
  helper_method :public_piwik

  rescue_from StandardError, with: :something_went_wrong unless Rails.env == 'development'
  rescue_from Errors::WarningLevelError, with: :something_went_wrong_warn
  rescue_from Api::SessionError, with: :session_error
  rescue_from Api::SessionTimeoutError, with: :session_timeout

  prepend RedirectWithSeeOther

  def transactions_list
    TRANSACTION_LISTER.list
  end

  def current_transaction
    @current_transaction ||= RELYING_PARTY_REPOSITORY.fetch(current_transaction_simple_id)
  end

  def current_transaction_simple_id
    session[:transaction_simple_id]
  end

  def set_current_transaction_simple_id(simple_id)
    session[:transaction_simple_id] = simple_id
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def validate_cookies
    validation = cookie_validator.validate(cookies)
    unless validation.ok?
      logger.info(validation.message)
      render_error(validation.type, validation.status)
    end
  end

  def set_secure_cookie(name, value)
    cookies[name] = {
      value: value,
      httponly: true,
      secure: Rails.configuration.x.cookies.secure
    }
  end

  def store_selected_evidence(stage, evidence)
    stored_selected_evidence[stage] = evidence
  end

  def stored_selected_evidence
    session[:selected_evidence] ||= {}
  end

  def selected_evidence_values
    stored_selected_evidence.values.flatten.map(&:to_sym)
  end

  def set_journey_hint(idp_entity_id, locale)
    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: idp_entity_id, locale: locale }.to_json
  end

  def journey_hint_value
    JSON.parse(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] ||= '')
  rescue JSON::ParserError
    nil
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

  def cookie_validator
    COOKIE_VALIDATOR
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

  def something_went_wrong(exception)
    logger.error(exception)
    render_error('something_went_wrong', :internal_server_error)
  end

  def something_went_wrong_warn(exception)
    logger.warn(exception)
    render_error('something_went_wrong', :internal_server_error)
  end

  def store_session_id
    RequestStore.store[:session_id] = request.cookies[CookieNames::SESSION_ID_COOKIE_NAME]
  end

  def store_originating_ip
    OriginatingIpStore.store(request)
  end

  def locale_from_journey_hint
    journey_hint_value.nil? ? I18n.default_locale : journey_hint_value['locale'].to_sym
  end

  def selected_identity_provider
    IdentityProvider.from_session(session.fetch(:selected_idp))
  end

  def current_identity_providers
    session[:identity_providers] ||= SESSION_PROXY.identity_providers(cookies)
    @current_identity_providers ||= session[:identity_providers].map { |obj| IdentityProvider.from_session(obj) }
  end

  def report_to_analytics(action_name)
    ANALYTICS_REPORTER.report(request, action_name)
  end

  def hide_available_languages
    @hide_available_languages = true
  end

  def for_viewable_idp(simple_id)
    matching_idp = current_identity_providers.detect { |idp| idp.simple_id == simple_id }
    idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if idp.viewable?
      yield idp
    else
      logger.error 'Unrecognised IdP simple id'
      render_not_found
    end
  end
end
