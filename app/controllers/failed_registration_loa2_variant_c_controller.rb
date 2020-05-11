require "partials/failed_registration_partial_controller"

class FailedRegistrationLoa2VariantCController < ApplicationController
  include FailedRegistrationPartialController

  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction
    @custom_fail = current_transaction.custom_fail_heading.present?
    @idp_recommendation_engine = IDP_RECOMMENDATION_ENGINE_variant_c
    render choose_partial_for_loa2
  end
end
