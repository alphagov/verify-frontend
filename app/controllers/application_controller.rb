require 'redirect_with_see_other'
class ApplicationController < ActionController::Base
  before_action :validate_session
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_filter :store_originating_ip
  after_action :store_locale_in_cookie, if: -> { request.method == 'GET' }
  helper_method :transactions_list
  helper_method :public_piwik

  rescue_from StandardError, with: :something_went_wrong unless Rails.env == 'development'
  rescue_from Errors::WarningLevelError, with: :something_went_wrong_warn
  rescue_from Api::SessionError, with: :session_error
  rescue_from Api::UpstreamError, with: :something_went_wrong_warn
  rescue_from Api::SessionTimeoutError, with: :session_timeout

  prepend RedirectWithSeeOther

  def transactions_list
    TRANSACTION_LISTER.list
  end

  def current_transaction
    @current_transaction ||= RP_DISPLAY_REPOSITORY.fetch(current_transaction_simple_id)
  end

  def current_transaction_simple_id
    session[:transaction_simple_id]
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

  def select_viewable_idp(entity_id)
    for_viewable_idp(entity_id) do |decorated_idp|
      session[:selected_idp] = decorated_idp.identity_provider
      yield decorated_idp
    end
  end

  def for_viewable_idp(entity_id)
    matching_idp = current_identity_providers.detect { |idp| idp.entity_id == entity_id }
    idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(matching_idp)
    if idp.viewable?
      yield idp
    else
      logger.error 'Unrecognised IdP simple id'
      render_not_found
    end
  end
end
