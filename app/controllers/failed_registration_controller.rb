class FailedRegistrationController < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    @transaction = current_transaction

    if CONTINUE_ON_FAILED_REGISTRATION_RPS.include?(current_transaction_simple_id)
      render_based_on_loa_level(:index_continue_on_failed_registration_LOA1, :index_continue_on_failed_registration_LOA2)
    else
      render_based_on_loa_level(:index_LOA1, :index_LOA2)
    end
  end

private

  def render_based_on_loa_level(loa1_template, loa2_template)
    if is_loa1?
      render loa1_template
    else
      render loa2_template
    end
  end
end
