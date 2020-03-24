class TestThrottlingCookieController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_after_action :store_locale_in_cookie

  def set_cookie
    cookies.encrypted[CookieNames::THROTTLING] = params[:idp]
    head :no_content
  end
end
