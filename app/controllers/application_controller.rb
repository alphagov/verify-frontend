require 'redirect_with_see_other'
require 'cookies/cookies'
require 'errors/warning_level_error'
require 'partials/user_characteristics_partial_controller'
require 'partials/user_errors_partial_controller'
require 'partials/user_cookies_partial_controller'
require 'partials/user_session_partial_controller'
require 'partials/transactions_partial_controller'
require 'partials/analytics_partial_controller'

class ApplicationController < ActionController::Base
  include DeviceType
  include UserErrorsPartialController
  include UserCharacteristicsPartialController
  include UserCookiesPartialController
  include UserSessionPartialController
  include TransactionsPartialController
  include AnalyticsPartialController

  before_action :validate_session
  before_action :set_visitor_cookie
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :store_originating_ip
  before_action :set_piwik_custom_variables
  after_action :store_locale_in_cookie, if: -> { request.method == 'GET' }
  after_action :delete_new_visit_flag

  helper_method :transaction_taxon_list
  helper_method :transactions_list
  helper_method :current_service
  helper_method :loa1_transactions_list
  helper_method :loa2_transactions_list
  helper_method :public_piwik

  rescue_from StandardError, with: :something_went_wrong unless Rails.env == 'development'
  rescue_from Errors::WarningLevelError, with: :something_went_wrong_warn
  rescue_from Api::SessionError, with: :session_error
  rescue_from Api::UpstreamError, with: :something_went_wrong_warn
  rescue_from Api::SessionTimeoutError, with: :session_timeout

  prepend RedirectWithSeeOther

private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def store_originating_ip
    OriginatingIpStore.store(request)
  end
end
