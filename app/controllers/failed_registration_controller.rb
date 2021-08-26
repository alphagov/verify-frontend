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
    if continue_on_failed_registration_rp?
      "failed_registration/continue_on_failed_registration_rp"
    elsif is_journey_loa2? && current_transaction.custom_fail_heading.present?
      "failed_registration/custom_failed_registration"
    else
      @tried_all_idps = tried_all_idps?
      "failed_registration/non_continue_on_failed_registration_rp"
    end
  end
end

def continue_on_failed_registration_rp?
  CONTINUE_ON_FAILED_REGISTRATION_RPS.include?(current_transaction_simple_id)
end

def tried_all_idps?
  possible_idps = current_available_identity_providers_for_registration

  if is_journey_loa2?
    suggested_idps = IDP_RECOMMENDATION_ENGINE.get_suggested_idps_for_registration(
      possible_idps,
      selected_evidence,
      current_transaction_simple_id,
    )

    possible_idps = suggested_idps[:recommended] + suggested_idps[:unlikely]
  end

  (possible_idps - idps_tried.to_a).none?
end
