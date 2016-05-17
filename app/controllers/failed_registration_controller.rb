class FailedRegistrationController < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction_name = current_transaction.name
  end
end
