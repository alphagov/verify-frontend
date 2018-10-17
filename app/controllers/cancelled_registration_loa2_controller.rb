class CancelledRegistrationLoa2Controller < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction

    render :cancelled_registration_LOA2, locals: { transaction: @transaction }
  end
end
