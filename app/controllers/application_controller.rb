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
    render_error('something_went_wrong', :internal_server_error)
  end

  rescue_from Api::Error do |exception|
    logger.error(exception)
    render_error('something_went_wrong', :internal_server_error)
  end

  rescue_from Api::SessionError do |exception|
    logger.error(exception)
    render_error('session_error', :bad_request)
  end

  rescue_from Api::SessionTimeoutError do |exception|
    logger.error(exception)
    render_error('session_timeout', :forbidden)
  end

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
      format.html { render "errors/#{partial}", status: status, layout: 'application'}
      format.json { render json: {}, status: status}
    end
  end

  def cookie_validator
    COOKIE_VALIDATOR
  end
end
