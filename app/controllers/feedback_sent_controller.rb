class FeedbackSentController < ApplicationController
  skip_before_action :validate_cookies

  def index
    flash.keep('email_provided')
    @email_provided = flash['email_provided']
    @session_valid = COOKIE_VALIDATOR.validate(cookies, session).ok?
    render
  end
end
