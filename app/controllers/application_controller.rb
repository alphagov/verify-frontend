require 'redirect_with_see_other'
require 'cookies/cookies'
require 'errors/warning_level_error'

class ApplicationController < ActionController::Base
  include DeviceType
  include UserErrors
  include UserCharacteristics
  include UserCookies
  include UserSession
  include Transactions
  include AnalyticsReporting

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  before_action :store_originating_ip


  prepend RedirectWithSeeOther

private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def store_originating_ip
    OriginatingIpStore.store(request)
  end
end
