class FeedbackSentController < ApplicationController
  skip_before_action :validate_session

  def index
    flash.keep('email_provided')
    @email_provided = flash['email_provided']
    @session_valid = session_validator.validate(cookies, session).ok?
    render
  end
end
