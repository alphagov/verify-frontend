class CancelledRegistrationController < ApplicationController
  before_action { @hide_feedback_link = true }

  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction
    @other_ways_decorated = @transaction.other_ways_description
    @other_ways_decorated[0] = @other_ways_decorated[0].capitalize

    render :cancelled_registration
  end
end
