# frozen_string_literal: true

require 'partials/user_cookies_partial_controller'
require 'partials/idp_selection_partial_controller'
require 'partials/viewable_idp_partial_controller'
require 'partials/retrieve_federation_data_partial_controller'

class SingleIdpJourneyController < ApplicationController
  layout 'slides'

  include IdpSelectionPartialController
  include ViewableIdpPartialController
  include RetrieveFederationDataPartialController

  protect_from_forgery except: :redirect_from_idp
  skip_before_action :validate_session, only: :redirect_from_idp
  skip_before_action :set_piwik_custom_variables, only: :redirect_from_idp

  def continue_to_your_idp
    if valid_cookie? && valid_selection?
      @idp = retrieve_decorated_singleton_idp_array_by_entity_id(current_identity_providers_for_single_idp, single_idp_cookie['idp_entity_id']).first
      @service_name = current_transaction.name
      @uuid = single_idp_cookie.fetch('uuid', nil)
      session[:journey_type] = 'single-idp'
      set_additional_piwik_custom_variable(:journey_type, 'SINGLE_IDP')
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
    if params_are_missing(%w(serviceId idpEntityId singleIdpJourneyIdentifier))
      redirect_to verify_services_path
    else
      transaction_id = params['serviceId']
      idp_entity_id = params['idpEntityId']
      uuid = params['singleIdpJourneyIdentifier'].to_s.downcase

      rp_url = get_single_idp_url(get_service_list, transaction_id)

      if rp_url.nil?
        logger.error "Could not get the RP URL for single IDP with transaction_id #{transaction_id} " + referrer_string
        redirect_to verify_services_path
      elsif !valid_request?(transaction_id, idp_entity_id, uuid)
        redirect_to verify_services_path
      else
        save_to_cookie(transaction_id, idp_entity_id, uuid)
        FEDERATION_REPORTER.report_started_single_idp_journey(request)
        logger.info "Successful Single IDP redirect to RP URL #{rp_url} from IdpId #{idp_entity_id} with uuid #{uuid}"
        redirect_to(rp_url)
      end
    end
  end

private

  def valid_uuid?(uuid)
    if /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.match?(uuid)
      true
    else
      logger.error "Single IDP UUID #{uuid} not valid" + referrer_string
      false
    end
  end

  def get_service_list
    CONFIG_PROXY.transactions_for_single_idp_list
  end

  def get_idp_list(transaction_id)
    list = CONFIG_PROXY.get_idp_list_for_single_idp(transaction_id)
    return nil if list.nil?
    list.idps
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
    if single_idp_cookie.nil?
      logger.error "Single IDP cookies was not found or was malformed" + referrer_string
      return false
    end
    true
  end

  def valid_selection?
    idp_entity_id = single_idp_cookie.fetch('idp_entity_id', nil)
    transaction_id = single_idp_cookie.fetch('transaction_id', nil)
    uuid = single_idp_cookie.fetch('uuid', nil)
    single_idp_rp_list = get_service_list

    return false if cookie_value_is_missing(%w(idp_entity_id transaction_id uuid))

    unless cookie_matches_session?(transaction_id)
      logger.error "The value of the Single IDP cookie does not match the session for transaction_id #{transaction_id}" + referrer_string
      return false
    end

    unless valid_transaction?(single_idp_rp_list, transaction_id)
      logger.error "The Single IDP transaction is not valid for transaction_id #{transaction_id}" + referrer_string
      return false
    end

    valid_request?(transaction_id, idp_entity_id, uuid)
  end

  def valid_request?(transaction_id, idp_entity_id, uuid)
    single_idp_idp_list = get_idp_list(transaction_id)

    if single_idp_idp_list.nil?
      logger.error "The IDP list for single IDP is empty for transaction_id #{transaction_id}" + referrer_string
      return false
    end

    unless valid_idp_choice?(single_idp_idp_list, idp_entity_id)
      logger.error "The IDP is not valid or disabled for transaction_id #{transaction_id} and idp_entity_id #{idp_entity_id}" + referrer_string
      return false
    end

    valid_uuid?(uuid)
  end

  def cookie_matches_session?(transaction)
    session[:transaction_entity_id] == transaction
  end

  def select_idp(entity_id, idp_name)
    POLICY_PROXY.select_idp(session[:verify_session_id], entity_id, session['requested_loa'])
    set_attempt_journey_hint(entity_id)
    session[:selected_idp_name] = idp_name
  end

  def params_are_missing(params_keys)
    params_are_missing = false
    params_keys.each do |param_key|
      if params[param_key].nil?
        logger.error "Single IDP parameter #{param_key} is missing" + referrer_string
        params_are_missing = true
        break
      end
    end
    params_are_missing
  end

  def cookie_value_is_missing(cookie_keys)
    value_is_missing = false
    cookie_keys.each do |cookie_key|
      if single_idp_cookie.fetch(cookie_key, nil).nil?
        logger.error "Single IDP cookie value for #{cookie_key} is missing" + referrer_string
        value_is_missing = true
        break
      end
    end
    value_is_missing
  end

  def referrer_string
    " - referrer: " + (request.nil? || request.referer.nil? ? "[could not get the referrer]" : request.referer)
  end
end
