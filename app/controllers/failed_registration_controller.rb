require "partials/viewable_idp_partial_controller"

class FailedRegistrationController < ApplicationController
  include ViewableIdpPartialController

  def index
    mark_idp_as_tried(selected_identity_provider.simple_id)

    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction
    render choose_view
  end

private

  def choose_view
    if is_journey_loa2? && current_transaction.custom_fail_heading.present?
      "failed_registration/custom_failed_registration"
    else
      @tried_all_idps = tried_all_idps?
      "failed_registration/failed_registration"
    end
  end
end

def tried_all_idps?
  possible_idps = identity_providers_available_for_registration
  (possible_idps - idps_tried.to_a).none?
end
