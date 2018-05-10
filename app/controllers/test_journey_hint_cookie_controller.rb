class TestJourneyHintCookieController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_after_action :store_locale_in_cookie
  layout 'test'

  def index
    render 'index'
  end

  def set_cookie
    if params['status'].blank?
      set_journey_hint(params['entity-id'])
    else
      set_journey_hint_by_status(params['entity-id'], params['status'])
    end
    head :no_content
  end
end
