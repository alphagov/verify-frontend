class FailedRegistrationController < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction_name = current_transaction.name

    if CONTINUE_ON_FAILED_REGISTRATION_RPS.include?(current_transaction_simple_id)
      @failed_registration_header = current_transaction.failed_registration_header
      @failed_registration_body = current_transaction.failed_registration_body

      render 'index_continue_on_failed_registration'
    else
      render 'index'
    end
  end
end
