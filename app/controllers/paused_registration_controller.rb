require "partials/user_cookies_partial_controller"
require "partials/journey_hinting_partial_controller"
require "partials/viewable_idp_partial_controller"
require "partials/retrieve_federation_data_partial_controller"
require "partials/idp_selection_partial_controller"
require "partials/analytics_cookie_partial_controller"

class PausedRegistrationController < ApplicationController
  include JourneyHintingPartialController
  include ViewableIdpPartialController
  include RetrieveFederationDataPartialController
  include IdpSelectionPartialController
  include UserCookiesPartialController
  include AnalyticsCookiePartialController

  # Validate the session manually within the action, as we don't want the normal 'no session' page.
  skip_before_action :validate_session, only: %i[index from_resume_link]
  skip_before_action :set_piwik_custom_variables, except: :resume
  layout "slides", only: :resume

  def index
    if session_is_valid?
      with_session
    elsif is_last_status?(PENDING_STATUS)
      with_cookie
    else
      render :without_user_session
    end
  end

  def from_resume_link
    idp_simple_id = params[:idp]
    if is_resume_link_for_pending_idp?(idp_simple_id)
      redirect_to paused_registration_path
    else
      @idp_display_data = IDP_DISPLAY_REPOSITORY.fetch(idp_simple_id, nil)
      if @idp_display_data.nil?
        render :without_user_session
      else
        set_resume_link_journey_hint(idp_simple_id)
        render :from_resume_link
      end
    end
  end

  def resume
    set_transaction_from_session
    @idp = get_idp_from_cookie
    if @idp.nil? || @transaction.nil?
      redirect_to start_path
    else
      journey_type = JourneyType::Verify::RESUMING
      session[:journey_type] = journey_type
      set_additional_piwik_custom_variable(:journey_type, journey_type.upcase)
      render :resume
    end
  end

  def resume_with_idp
    select_viewable_idp_for_sign_in(params.fetch("entity_id")) do |decorated_idp|
      select_resume(decorated_idp.entity_id, decorated_idp.display_name)
      redirect_to redirect_to_idp_resume_path
    end
  end

  def resume_with_idp_ajax
    select_viewable_idp_for_sign_in(params.fetch("entityId")) do |decorated_idp|
      select_resume(decorated_idp.entity_id, decorated_idp.display_name)
      ajax_idp_redirection_resume_journey_request
    end
  end

private

  def session_is_valid?
    session_validator.validate(cookies, session).ok? && session.key?(:selected_provider) && !selected_identity_provider.nil?
  end

  def get_idp_from_cookie
    from_resume_link_idp_value = resume_link_idp
    if from_resume_link_idp_value.nil?
      last_idp_value = last_idp
      last_idp_value && decorate_idp_by_entity_id(current_available_identity_providers_for_registration, last_idp_value)
    else
      decorate_idp_by_simple_id(current_available_identity_providers_for_registration, from_resume_link_idp_value)
    end
  end

  def with_session
    set_transaction_from_session
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    render :with_user_session
  end

  def with_cookie
    set_transaction_from_cookie

    if last_verify_journey_type == JourneyType::Verify::SIGN_IN
      @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(get_idp_from_idps_available_for_sign_in)
      render :with_user_session
    elsif (idp = get_idp_from_idps_available_for_registration)
      @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(idp)
      render :with_user_session
    elsif (idp = get_idp_from_idps_available_for_sign_in)
      @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(idp)
      render :idp_no_longer_providing_registrations
    else
      raise(Errors::WarningLevelError, "IDP not found in those providing registration or sign in. IDP was '#{last_idp}'")
    end
  end

  def set_transaction_from_session
    selected_rp = get_rp_details(current_transaction_entity_id)
    return if selected_rp.nil?

    @transaction = {
      name: current_transaction.name,
      homepage: current_transaction_homepage,
      start_page: preferred_start_page(selected_rp),
    }
  end

  def set_transaction_from_cookie
    selected_rp = get_rp_details(last_rp)
    return if selected_rp.nil?

    @transaction = {
      name: get_translated_service_name(selected_rp.simple_id),
      homepage: selected_rp.transaction_homepage,
      start_page: preferred_start_page(selected_rp),
    }
  end

  def get_rp_details(last_rp_value)
    return nil if last_rp_value.nil?

    CONFIG_PROXY.get_transaction_details(last_rp_value)
  rescue Api::Error => e
    logger.warn "Error trying to retrieve transaction details for #{last_rp_value}. #{e}"
    nil
  end

  def get_translated_service_name(simple_id)
    CONFIG_PROXY.get_transaction_translations(simple_id, params[:locale]).fetch(:name, nil)
  end

  def get_idp_list_for_registration(transaction_id)
    list = CONFIG_PROXY.get_available_idp_list_for_registration(transaction_id, "LEVEL_2")
    return nil if list.nil?

    list.idps
  end

  def get_idp_list_for_sign_in
    list = CONFIG_PROXY.get_idp_list_for_sign_in(last_rp)
    return nil if list.nil?

    list.idps
  end

  def get_idp_from_idps_available_for_sign_in
    get_idp_choice(get_idp_list_for_sign_in, last_idp)
  end

  def get_idp_from_idps_available_for_registration
    get_idp_choice(get_idp_list_for_registration(last_rp), last_idp)
  end

  def preferred_start_page(selected_rp)
    selected_rp.headless_startpage.nil? ? selected_rp.transaction_homepage : selected_rp.headless_startpage
  end

  def select_resume(entity_id, idp_name)
    POLICY_PROXY.select_idp(session[:verify_session_id],
                            entity_id,
                            session[:requested_loa],
                            false,
                            persistent_session_id,
                            session[:journey_type],
                            ab_test_with_alternative_name)
    set_attempt_journey_hint(entity_id)
    session[:selected_idp_name] = idp_name
  end

  def is_resume_link_for_pending_idp?(idp_simple_id)
    return false unless is_last_status?(PENDING_STATUS)

    idp = decorate_idp_by_entity_id(current_available_identity_providers_for_registration, last_idp)

    !idp.nil? && idp.simple_id == idp_simple_id
  end
end
