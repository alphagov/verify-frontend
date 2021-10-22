require "partials/user_cookies_partial_controller"
require "partials/retrieve_federation_data_partial_controller"

class PausedRegistrationController < IdpSelectionController
  include RetrieveFederationDataPartialController
  include UserCookiesPartialController

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
      journey_type = JourneyType::RESUMING
      session[:journey_type] = journey_type
      set_additional_piwik_custom_variable(:journey_type, journey_type.upcase)
      render :resume
    end
  end

  def resume_with_idp
    select_idp_for_resumed_registration(params.fetch("entity_id", nil)) { redirect_to_idp }
  end

  def resume_with_idp_ajax
    select_idp_for_resumed_registration(params.fetch("entityId", nil)) { ajax_idp_redirection_request }
  end

private

  def select_idp_for_resumed_registration(entity_id)
    register_idp_selection_in_session(entity_id) do
      FEDERATION_REPORTER.report_idp_resume_journey_selection(current_transaction: current_transaction, request: request, idp_name: session[:selected_idp_name])
      yield
    end
  end

  def session_is_valid?
    session_validator.validate(cookies, session).ok? && session.key?(:selected_provider) && !selected_identity_provider.nil?
  end

  def get_idp_from_cookie
    from_resume_link_idp_value = resume_link_idp
    if from_resume_link_idp_value.nil?
      last_idp_value = last_idp
      last_idp_value && decorate_idp_by_entity_id(identity_providers_available_for_registration, last_idp_value)
    else
      decorate_idp_by_simple_id(identity_providers_available_for_registration, from_resume_link_idp_value)
    end
  end

  def with_session
    set_transaction_from_session
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    render :with_user_session
  end

  def with_cookie
    set_transaction_from_cookie

    if last_verify_journey_type == JourneyType::SIGN_IN
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

  def is_resume_link_for_pending_idp?(idp_simple_id)
    return false unless is_last_status?(PENDING_STATUS)

    idp = decorate_idp_by_entity_id(identity_providers_available_for_registration, last_idp)

    idp&.simple_id == idp_simple_id
  end
end
