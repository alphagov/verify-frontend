class TestJourneyHintCookieController < ApplicationController
  skip_before_action :validate_cookies
  layout 'test'

  def index
    render 'index'
  end

  def set_cookie
    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = params['entity-id']
    render nothing: true
  end
end
