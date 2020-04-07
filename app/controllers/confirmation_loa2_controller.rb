class ConfirmationLoa2Controller < ApplicationController
  before_action { @hide_feedback_link = true }
  layout "slides"

  def matching_journey
    journey_confirmation(true)
  end

  def non_matching_journey
    journey_confirmation(false)
    report_to_analytics("Outcome - Matching Not Used By Service")
  end

private

  def journey_confirmation(matching)
    @idp_name = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider).display_name
    @transaction_name = current_transaction.name
    @redirect_path = matching ? response_processing_path : redirect_to_service_signing_in_path
    render :confirmation_LOA2
  end
end
