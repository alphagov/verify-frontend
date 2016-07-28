class FeedbackSentController < ApplicationController
  skip_before_action :validate_cookies

  def index
    flash.keep('email_provided')
    @email_provided = flash['email_provided']
    session_id_cookie = cookies[CookieNames::SESSION_ID_COOKIE_NAME]
    @session_valid = session_id_cookie && session_id_cookie != CookieNames::NO_CURRENT_SESSION_VALUE
    render
  end
end
