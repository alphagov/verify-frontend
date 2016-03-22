require 'redirect_with_see_other'
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_filter :store_session_id
  before_action :validate_cookies
  helper_method :transactions_list
  helper_method :public_piwik

  rescue_from StandardError, with: :something_went_wrong
  rescue_from Api::SessionError, with: :session_error
  rescue_from Api::SessionTimeoutError, with: :session_timeout

  prepend RedirectWithSeeOther

  def transactions_list
    TRANSACTION_LISTER.list
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

private

  def render_error(partial, status)
    respond_to do |format|
      format.html { render "errors/#{partial}", status: status, layout: 'application' }
      format.json { render json: {}, status: status }
    end
  end

  def cookie_validator
    COOKIE_VALIDATOR
  end

  def public_piwik
    PUBLIC_PIWIK
  end

  def session_timeout(exception)
    logger.error(exception)
    render_error('session_timeout', :forbidden)
  end

  def session_error(exception)
    logger.error(exception)
    render_error('session_error', :bad_request)
  end

  def something_went_wrong(exception)
    logger.error(exception)
    Raven.capture_exception(exception)
    render_error('something_went_wrong', :internal_server_error)
  end

  def store_session_id
    RequestStore.store[:session_id] = request.cookies[CookieNames::SESSION_ID_COOKIE_NAME]
  end
end
