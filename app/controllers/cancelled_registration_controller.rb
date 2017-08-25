class CancelledRegistrationController < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @service_name = current_transaction.name

    if is_loa1?
      render :cancelled_registration_LOA1
    else
      render :cancelled_registration_LOA2
    end
  end
end
