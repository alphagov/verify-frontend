require "partials/user_cookies_partial_controller"
require "partials/viewable_idp_partial_controller"
require "partials/journey_hinting_partial_controller"

class CompletedRegistrationController < ApplicationController
  include UserCookiesPartialController
  include ViewableIdpPartialController
  include JourneyHintingPartialController

  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def index
    idp_simple_id = params[:idp]
    @idp = IDP_DISPLAY_REPOSITORY.fetch(idp_simple_id, nil)
    if @idp.nil?
      redirect_to verify_services_path
    else
      # Hack - we need and IDP list, but the current API needs a transaction
      session[:transaction_entity_id] = "https://wwwm.universal-credit.service.gov.uk"
      identity_providers = current_available_identity_providers_for_sign_in
      session[:transaction_entity_id] = nil

      entity_id = decorate_idp_by_simple_id(identity_providers, idp_simple_id).entity_id
      set_attempt_journey_hint(entity_id)
      set_journey_hint_by_status(entity_id, "SUCCESS")
      remove_resume_link_journey_hint
      render :index
    end
  end
end
