class TestJourneyHintCookieController < ApplicationController
  skip_before_action :validate_cookies
  layout 'test'

  def index
    render 'index'
  end

  def set_cookie
    set_journey_hint(params['entity-id'], params['locale'])
    render nothing: true
  end
end
