class TestJourneyHintCookieController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_after_action :store_locale_in_cookie
  layout 'test'

  def index
    render 'index'
  end

  def set_cookie
    if old_cookie?
      set_old_cookie
    else
      set_new_cookie
    end
    head :no_content
  end

private

  def old_cookie?
    params['status'].blank?
  end

  def set_old_cookie
    set_journey_hint(params['entity-id'], false)
  end

  def set_new_cookie
    set_journey_hint(params['entity-id'])
    set_journey_hint_by_status(params['entity-id'], params['status'])
  end
end
