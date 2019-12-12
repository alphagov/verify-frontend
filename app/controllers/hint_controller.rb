require 'partials/journey_hinting_partial_controller'
require 'partials/retrieve_federation_data_partial_controller'
require 'partials/viewable_idp_partial_controller'

class HintController < ApplicationController
  include JourneyHintingPartialController
  include RetrieveFederationDataPartialController
  include ViewableIdpPartialController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_before_action :verify_authenticity_token

  def ajax_request
    set_headers

    entity_id = attempted_entity_id

    json_object = { 'status': 'OK', 'value': !entity_id.nil? }

    render json: json_object.to_json, callback: params['callback']
  end

  def last_successful_idp
    set_headers

    entity_id = success_entity_id
    identity_providers = current_available_identity_providers_for_sign_in

    if entity_id && identity_providers.any?
      idp = retrieve_decorated_singleton_idp_array_by_entity_id(
        identity_providers,
        entity_id
      ).first

      json_object = {
        'found': 'true',
        'simpleId': idp.simple_id,
        'displayName': idp.display_name
      }
    else
      json_object = { 'found': 'false' }
    end

    render json: json_object.to_json, callback: params['callback']
  end

  def set_headers
    response.headers['Access-Control-Allow-Origin'] = 'https://www.gov.uk'
    response.headers['Access-Control-Request-Method'] = 'GET'
  end
end
