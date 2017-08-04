class CancelledRegistrationController < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @service_name = current_transaction.name

    render :index
  end
end
