require "partials/retrieve_federation_data_partial_controller"
require "partials/analytics_cookie_partial_controller"

class SingleIdpJourneyController < IdpSelectionController
  include RetrieveFederationDataPartialController
  include AnalyticsCookiePartialController

  skip_before_action :verify_authenticity_token, only: :redirect_from_idp
  skip_before_action :validate_session, only: %i{redirect_from_idp rp_start_page}
  skip_before_action :set_piwik_custom_variables, only: %i{redirect_from_idp rp_start_page}

  before_action :do_not_cache

  layout "slides", except: :rp_start_page

  def continue_to_your_idp
    if valid_cookie? && valid_selection?
      @idp = decorate_idp_by_entity_id(identity_providers_for_single_idp, single_idp_cookie["idp_entity_id"])
      @service_name = current_transaction.name
      @uuid = single_idp_cookie.fetch("uuid", nil)
      session[:journey_type] = JourneyType::SINGLE_IDP
      set_additional_piwik_custom_variable(:journey_type, "SINGLE_IDP")
      FEDERATION_REPORTER.report_single_idp_success(current_transaction, request, session[:transaction_entity_id], @uuid)
      render
    else
      redirect_to start_path
    end
  end

  def continue
    entity_id = params.fetch("entity_id", nil)
    return redirect_to start_path if !entity_id || entity_id.empty?

    unless select_idp_for_single_idp_journey(entity_id) do |uuid|
      redirect_to_idp(uuid)
    end
      render_error :session_error, :bad_request
    end
  end

  def continue_ajax
    unless select_idp_for_single_idp_journey(params.fetch("entityId", nil)) do |uuid|
      ajax_idp_redirection_request(uuid)
    end
      ajax_idp_redirection_request
    end
  end

  def redirect_from_idp
    if params_are_missing(%w(serviceId idpEntityId singleIdpJourneyIdentifier))
      redirect_to verify_services_path
    else
      transaction_id = params["serviceId"]
      idp_entity_id = params["idpEntityId"]
      uuid = params["singleIdpJourneyIdentifier"].to_s.downcase

      set_transaction_entity_id transaction_id
      rp_url = get_single_idp_url(get_service_list, transaction_id)

      if rp_url.nil?
        logger.error "Could not get the RP URL for single IDP with transaction_id #{transaction_id} " + referrer_string
        redirect_to verify_services_path
      elsif !valid_request?(transaction_id, idp_entity_id, uuid)
        redirect_to(rp_url)
      else
        save_to_cookie(transaction_id, idp_entity_id, uuid)
        FEDERATION_REPORTER.report_started_single_idp_journey(request)
        logger.info "Successful Single IDP redirect to RP URL #{rp_url} from IDP with entity ID #{idp_entity_id} and UUID #{uuid}"
        redirect_to(rp_url)
      end
    end
  end

  def rp_start_page
    @simple_id_value = params.fetch("transaction_simple_id", nil)

    @transaction = CONFIG_PROXY.get_transaction_by_simple_id(@simple_id_value) unless @simple_id_value.nil?
    return render "errors/404" if @transaction.nil?

    @hide_available_languages = true
    @headless_start_page = @transaction.nil? ? nil : @transaction.fetch("headlessStartpage")
    @translation = CONFIG_PROXY.get_transaction_translations(@simple_id_value, params["locale"])
    @english_translation = CONFIG_PROXY.get_transaction_translations(@simple_id_value, "en")
    return render "errors/404" if @translation[:single_idp_start_page_content_html].nil?

    render
  end

private

  def select_idp_for_single_idp_journey(entity_id)
    register_idp_selection_in_session(entity_id) do
      if valid_cookie?
        FEDERATION_REPORTER.report_single_idp_journey_selection(current_transaction: current_transaction, request: request, idp_name: session[:selected_idp_name])
        yield single_idp_cookie&.fetch("uuid", nil)
        return true
      end
    end
  end

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

  def save_to_cookie(transaction_id, idp_entity_id, uuid)
    data = {
      transaction_id: transaction_id,
      idp_entity_id: idp_entity_id,
      uuid: uuid,
    }
    set_single_idp_journey_cookie(data)
  end

  def valid_selection?
    return false if cookie_value_is_missing(%w(idp_entity_id transaction_id uuid))

    idp_entity_id = single_idp_cookie.fetch("idp_entity_id", nil)
    transaction_id = single_idp_cookie.fetch("transaction_id", nil)
    uuid = single_idp_cookie.fetch("uuid", nil)
    single_idp_rp_list = get_service_list

    unless identity_providers_for_single_idp.select(&:unavailable).select { |idp| idp.entity_id == idp_entity_id }.empty?
      logger.info "IDP #{idp_entity_id} is unavailable so not valid for single IDP" + referrer_string
      return false
    end

    unless cookie_matches_session?(transaction_id)
      actual_service_identifier = session[:transaction_entity_id]
      FEDERATION_REPORTER.report_single_idp_service_mismatch(
        current_transaction, request, transaction_id, actual_service_identifier, uuid
      )
      logger.info "The value of the Single IDP cookie does not match the session value of #{actual_service_identifier}"\
                      " for transaction_id #{transaction_id} with uuid #{uuid}"
      return false
    end

    unless valid_transaction?(single_idp_rp_list, transaction_id)
      logger.error "The Single IDP transaction is not valid for transaction_id #{transaction_id}" + referrer_string
      return false
    end

    valid_request?(transaction_id, idp_entity_id, uuid)
  end

  def valid_request?(transaction_id, idp_entity_id, uuid)
    single_idp_idp_list = identity_providers_for_single_idp

    if single_idp_idp_list.nil?
      logger.error "The IDP list for single IDP is empty for transaction_id #{transaction_id}" + referrer_string
      return false
    end

    unless valid_idp_choice?(single_idp_idp_list, idp_entity_id)
      logger.warn "The IDP is not valid or disabled for transaction_id #{transaction_id} and idp_entity_id #{idp_entity_id}" + referrer_string
      return false
    end

    valid_uuid?(uuid)
  end

  def cookie_matches_session?(transaction)
    session[:transaction_entity_id] == transaction
  end

  def params_are_missing(params_keys)
    params_keys.each do |param_key|
      if params[param_key].nil? || params[param_key].blank?
        logger.warn "Single IDP parameter #{param_key} is missing" + referrer_string
        return true
      end
    end
    false
  end

  def cookie_value_is_missing(cookie_keys)
    cookie_keys.each do |cookie_key|
      if single_idp_cookie.fetch(cookie_key, nil).nil?
        logger.error "Single IDP cookie value for #{cookie_key} is missing" + referrer_string
        return true
      end
    end
    false
  end

  def do_not_cache
    response.headers["Cache-Control"] = "no-cache, no-store, no-transform"
  end

  def single_idp_cookie
    MultiJson.load(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY])
  rescue MultiJson::ParseError
    nil
  end

  def valid_cookie?
    if single_idp_cookie.nil?
      # This is still valid behaviour, it can be the users session has genuinely expired,
      # or that the session has been tampered with.
      logger.warn "Single IDP cookie was not found or was malformed" + referrer_string
      FEDERATION_REPORTER.report_single_idp_invalid_cookie(current_transaction, request)
      return false
    end
    true
  end

  def referrer_string
    " - referrer: " + (request&.referer || "[could not get the referrer]")
  end
end
