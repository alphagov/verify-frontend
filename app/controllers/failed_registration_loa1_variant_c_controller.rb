require "partials/failed_registration_partial_controller"

class FailedRegistrationLoa1VariantCController < ApplicationController
  include FailedRegistrationPartialController

  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction
    @idp_recommendation_engine = IDP_RECOMMENDATION_ENGINE_variant_c
    render choose_partial_for_loa1
  end
end
