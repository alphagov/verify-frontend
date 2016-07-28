class FeedbackSentController < ApplicationController
  skip_before_action :validate_cookies

  def index
    flash.keep('email_provided')
    @email_provided = flash['email_provided']
    @session_valid = cookies.has_key?(CookieNames::SESSION_ID_COOKIE_NAME)
    render
  end
end
