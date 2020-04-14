require "partials/journey_hinting_partial_controller"
class TestJourneyHintCookieController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_after_action :store_locale_in_cookie
  include JourneyHintingPartialController
  layout "test"

  def index
    @current_cookie = journey_hint_value.as_json
    render "index"
  end

  def set_cookie
    if params["status"].blank?
      set_attempt_journey_hint(params["entity-id"])
    else
      set_journey_hint_by_status(params["entity-id"], params["status"], params["rp-entity-id"])
      set_resume_link_journey_hint(params["resume-link-simple-id"]) unless params["resume-link-simple-id"].blank?
    end
    head :no_content
  end
end
