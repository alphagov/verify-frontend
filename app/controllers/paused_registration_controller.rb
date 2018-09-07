class PausedRegistrationController < ApplicationController
  # Validate the session manually within the action, as we don't want the normal 'no session' page.
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def index
    if session_is_valid
      @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
      @transaction = {
          name: current_transaction.rp_name,
          homepage: current_transaction_homepage
      }
      render :with_user_session
    else
      render :without_user_session
    end
  end

private

  def session_is_valid
    session_validator.validate(cookies, session).ok? && session.key?(:selected_provider) && !selected_identity_provider.nil?
  end
end
