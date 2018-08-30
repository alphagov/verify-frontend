# frozen_string_literal: true

require 'partials/user_cookies_partial_controller'

class InitiateSingleIdpJourneyController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def redirect_from_idp
    transaction_id = params['serviceId']
    idp_entity_id = params['idpEntityId']
    uuid = params['singleIdpJourneyIdentifier'].to_s.downcase
    rp_url = get_service_choice_url(transaction_id)

    if !rp_url.empty? && valid_idp_choice?(idp_entity_id) && valid_uuid?(uuid)
      save_to_session(transaction_id, idp_entity_id, uuid)
      FEDERATION_REPORTER.report_started_single_idp_journey(request)
      redirect_to(rp_url)
    else
      redirect_to verify_services_path
    end
  end

private

  def valid_uuid?(uuid)
    /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match?(uuid)
  end

  def get_service_choice_url(transaction_id)
    begin
      url = SINGLE_IDP_ENABLED_RP_LIST[transaction_id]['url']
      return url
    rescue NoMethodError
      return ''
    end
  end

  def valid_idp_choice?(idp_entity_id)
    SINGLE_IDP_ENABLED_IDP_LIST.include?(idp_entity_id)
  end

  def save_to_session(transaction_id, idp_entity_id, uuid)
    data = {
        transaction_id: transaction_id,
        idp_entity_id: idp_entity_id,
        uuid: uuid
    }
    set_single_idp_journey_cookie(data)
  end
end
