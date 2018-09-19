require 'partials/user_cookies_partial_controller'
require 'partials/journey_hinting_partial_controller'
require 'partials/viewable_idp_partial_controller'


class PausedRegistrationController < ApplicationController
  include JourneyHintingPartialController
  include ViewableIdpPartialController

  # Validate the session manually within the action, as we don't want the normal 'no session' page.
  skip_before_action :validate_session, except: :resume
  skip_before_action :set_piwik_custom_variables, except: :resume
  layout 'slides', except: :index

  def index
    if session_is_valid
      set_transaction_from_session
      @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
      render :with_user_session
    else
      render :without_user_session
    end
  end

  def resume
    set_transaction_from_session
    @idp = get_idp_from_cookie
    if @idp.nil?
      redirect_to start_path
    else
      render :resume_with_idp
    end
  end

private

  def session_is_valid
    session_validator.validate(cookies, session).ok? && session.key?(:selected_provider) && !selected_identity_provider.nil?
  end

  def get_idp_from_cookie
    last_idp_value = last_idp
    unless last_idp_value.nil?
      return retrieve_decorated_singleton_idp_array_by_entity_id(current_identity_providers_for_sign_in, last_idp_value)[0]
    end
  end

  def set_transaction_from_session
    @transaction = {
        name: current_transaction.name,
        homepage: current_transaction_homepage
    }
  end
end
