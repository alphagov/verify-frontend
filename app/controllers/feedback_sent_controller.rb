class FeedbackSentController < ApplicationController
  skip_before_action :validate_cookies

  def index
    @email_provided = params['emailProvided'] == 'true'
    render
  end
end