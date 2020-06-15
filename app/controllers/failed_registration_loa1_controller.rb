require "partials/failed_registration_partial_controller"

class FailedRegistrationLoa1Controller < ApplicationController
  include FailedRegistrationPartialController

  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction
    @idp_recommendation_engine = IDP_RECOMMENDATION_ENGINE
    render view_for_loa1
  end

private

  def view_for_loa1
    choose_view "LOA1"
  end
end
