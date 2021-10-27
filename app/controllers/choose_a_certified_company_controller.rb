class ChooseACertifiedCompanyController < IdpSelectionController
  skip_before_action :render_cross_gov_ga, only: [:about]

  def index
    @idps = order_with_unavailable_last(IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(identity_providers_available_for_registration))
    return something_went_wrong("No IDPs available for registration") if @idps.empty?

    render :choose_a_certified_company
  end

  def about
    selected_idp = identity_providers_available_for_registration.detect { |idp| idp.simple_id == params[:company] }
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_idp)
    return something_went_wrong("Selected IDP is not viewable", :not_found) unless @idp.viewable?

    render :about
  end

  def select_idp
    select_idp_for_registration(params.fetch(:entity_id, nil)) { redirect_to_idp }
  end

  def select_idp_ajax
    select_idp_for_registration(params.fetch("entityId", nil)) { ajax_idp_redirection_request }
  end

private

  def select_idp_for_registration(entity_id)
    session[:journey_type] = JourneyType::REGISTRATION
    register_idp_selection_in_session(entity_id) do |decorated_idp|
      track_selected_idp decorated_idp.display_name
      report_idp_registration_to_piwik
      yield
    end
  end

  def report_idp_registration_to_piwik
    FEDERATION_REPORTER.report_idp_registration(
      current_transaction: current_transaction,
      request: request,
      idp_name: session[:selected_idp_name],
      idp_name_history: session[:selected_idp_names],
    )
  end
end
