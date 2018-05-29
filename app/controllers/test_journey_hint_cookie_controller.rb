class TestJourneyHintCookieController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_after_action :store_locale_in_cookie
  layout 'test'

  def index
    render 'index'
  end

  def set_old_cookie
    set_journey_hint(params['entity-id-old'], false)
    head :no_content
  end

  def set_cookie
    set_journey_hint(params['entity-id'])
    set_journey_hint_by_status(params['entity-id'], params['status']) unless params['status'].blank?
    head :no_content
  end
end
