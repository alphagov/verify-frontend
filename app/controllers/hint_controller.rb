require 'partials/journey_hinting_partial_controller'

class HintController < ApplicationController
  include JourneyHintingPartialController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_before_action :verify_authenticity_token

  def ajax_request
    set_headers

    entity_id = attempted_entity_id

    json_object = { 'status': 'OK', 'value': !entity_id.nil? }

    render json: json_object.to_json, callback: params['callback']
  end

  def set_headers
    response.headers['Access-Control-Allow-Origin'] = 'https://www.gov.uk'
    response.headers['Access-Control-Request-Method'] = 'GET'
  end
end
