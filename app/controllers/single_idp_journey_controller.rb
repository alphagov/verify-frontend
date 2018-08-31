# frozen_string_literal: true

require 'partials/user_cookies_partial_controller'
require 'partials/idp_selection_partial_controller'
require 'partials/viewable_idp_partial_controller'

class SingleIdpJourneyController < ApplicationController
  layout 'slides'

  include IdpSelectionPartialController
  include ViewableIdpPartialController

  protect_from_forgery except: :redirect_from_idp
  skip_before_action :validate_session, except: %i[index continue continue_ajax]
  skip_before_action :set_piwik_custom_variables, except: %i[index continue continue_ajax]

  def continue_to_your_idp
    if valid_cookie? && valid_selection?
      @idp = retrieve_decorated_singleton_idp_array_by_entity_id(current_identity_providers_for_sign_in, single_idp_cookie['idp_entity_id'])[0]
      @service_name = current_transaction.name
      @uuid = single_idp_cookie.fetch('uuid', nil)
      session[:journey_type] = 'single-idp'
      render
    else
      redirect_to start_path
    end
  end

  def continue
    select_viewable_idp_for_single_idp_journey(params.fetch('entity_id')) do |decorated_idp|
      select_idp(decorated_idp.entity_id, decorated_idp.display_name)
      redirect_to redirect_to_single_idp_path
    end
  end

  def continue_ajax
    select_viewable_idp_for_single_idp_journey(params.fetch('entityId')) do |decorated_idp|
      select_idp(decorated_idp.entity_id, decorated_idp.display_name)
      ajax_idp_redirection_single_idp_journey_request(single_idp_cookie.fetch('uuid', nil))
    end
  end

  def redirect_from_idp
    transaction_id = params['serviceId']
    idp_entity_id = params['idpEntityId']
    uuid = params['singleIdpJourneyIdentifier'].to_s.downcase
    rp_url = get_service_choice_url(transaction_id)

    if !rp_url.empty? && valid_idp_choice?(idp_entity_id) && valid_uuid?(uuid)
      save_to_cookie(transaction_id, idp_entity_id, uuid)
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

  def valid_transaction?(_transaction_entity_id)
    true # to be implemented with config changes - check current_transaction vs cookie transaction
  end

  def save_to_cookie(transaction_id, idp_entity_id, uuid)
    data = {
        transaction_id: transaction_id,
        idp_entity_id: idp_entity_id,
        uuid: uuid
    }
    set_single_idp_journey_cookie(data)
  end

  def single_idp_cookie
    MultiJson.load(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY])
  rescue MultiJson::ParseError
    nil
  end

  def valid_cookie?
    !single_idp_cookie.nil?
  end

  def valid_selection?
    idp = single_idp_cookie.fetch('idp_entity_id', nil)
    transaction = single_idp_cookie.fetch('transaction_id', nil)
    uuid = single_idp_cookie.fetch('uuid', nil)
    valid_idp_choice?(idp) && valid_transaction?(transaction) && valid_uuid?(uuid)
  end

  def select_idp(entity_id, idp_name)
    POLICY_PROXY.select_idp(session[:verify_session_id], entity_id, session['requested_loa'])
    set_journey_hint(entity_id)
    session[:selected_idp_name] = idp_name
  end
end
