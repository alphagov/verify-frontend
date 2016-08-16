class TestJourneyHintCookieController < ApplicationController
  skip_before_action :validate_session
  skip_after_action :store_locale_in_cookie
  layout 'test'

  def index
    render 'index'
  end

  def set_cookie
    set_journey_hint(params['entity-id'])
    head :no_content
  end
end
