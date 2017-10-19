class CancelledRegistrationLoa2Controller < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @service_name = current_transaction.name

    render :cancelled_registration_LOA2
  end
end
