require 'partials/journey_hinting_partial_controller'

class HintController < ApplicationController
  include JourneyHintingPartialController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def ajax_request
    set_headers

    entity_id = entity_id_of_journey_hint

    render json: { 'status': 'OK', 'value': !entity_id.nil? }
  end

  def set_headers
    response.headers['Access-Control-Allow-Origin'] = 'https://www.gov.uk'
    response.headers['Access-Control-Request-Method'] = 'GET'
  end
end
