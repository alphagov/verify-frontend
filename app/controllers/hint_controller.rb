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

    entity_id = success_entity_id

    json_object = { 'status': 'OK', 'value': !entity_id.nil? }

    render json: json_object.to_json, callback: params['callback']
  end

  def last_successful_idp
    set_headers

    entity_id = success_entity_id

    return render json: { 'found': 'false' }.to_json, callback: params['callback'] if entity_id.nil?

    # Ugly and temporary hack (due to time constraints)
    # We need the list of enabled IDPs, but these lists are mapped against a transaction
    # at this stage there's no transaction but we know this is called from PTA page
    session[:transaction_entity_id] = 'https://prod-left.tax.service.gov.uk/SAML2/PERTAX'
    identity_providers = current_available_identity_providers_for_sign_in

    if identity_providers.any?
      idp = retrieve_decorated_singleton_idp_array_by_entity_id(
        identity_providers,
        entity_id
      ).first

      if idp.nil?
        logger.info "No IDP found for entity ID #{entity_id} and identity providers #{identity_providers}"
        json_object = { 'found': 'false' }
      else
        json_object = {
          'found': 'true',
          'simpleId': idp.simple_id,
          'displayName': idp.display_name
        }
      end
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
