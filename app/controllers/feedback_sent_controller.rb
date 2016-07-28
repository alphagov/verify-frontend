class FeedbackSentController < ApplicationController
  skip_before_action :validate_cookies

  def index
    @email_provided = params['emailProvided'] == 'true'
    @session_valid = cookies.has_key?(CookieNames::SESSION_ID_COOKIE_NAME)
    render
  end
end
