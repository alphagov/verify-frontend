class ConfirmationController < ApplicationController
  before_action :hide_feedback_link
  layout 'slides'

  def index
    @idp_name = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider).display_name
    @transaction_name = current_transaction.name

    if is_loa1?
      render :confirmation_LOA1
    else
      render :confirmation_LOA2
    end
  end
end
