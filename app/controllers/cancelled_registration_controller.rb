require "partials/viewable_idp_partial_controller"

class CancelledRegistrationController < ApplicationController
  include ViewableIdpPartialController
  before_action { @hide_feedback_link = true }

  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction
    @other_ways_decorated = @transaction.other_ways_description
    @other_ways_decorated[0] = @other_ways_decorated[0].capitalize
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(identity_providers_available_for_registration)

    render :cancelled_registration
  end
end
