class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :validate_cookies
  helper_method :transactions_list

  rescue_from StandardError do |exception|
    logger.error(exception)
    #exception.backtrace.each { |line| logger.error(line) }
    render "errors/something_went_wrong"
  end

  rescue_from ApiClient::SessionError do |exception|
    logger.error(exception)
    render "errors/session_error"
  end

  rescue_from ApiClient::SessionTimeoutError do |exception|
    logger.error(exception)
    render "errors/session_timeout"
  end

  def transactions_list
    TRANSACTION_LISTER.list
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def validate_cookies
    validation = cookie_validator.validate(cookies)
    render_error(validation) unless validation.ok?
  end

private

  def render_error(validation)
    logger.info(validation.message)
    render "errors/#{validation.type}", status: validation.status
  end

  def cookie_validator
    COOKIE_VALIDATOR
  end
end
