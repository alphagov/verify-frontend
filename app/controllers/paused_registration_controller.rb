require 'partials/user_cookies_partial_controller'
require 'partials/journey_hinting_partial_controller'
require 'partials/viewable_idp_partial_controller'
require 'partials/retrieve_federation_data_partial_controller'



class PausedRegistrationController < ApplicationController
  include JourneyHintingPartialController
  include ViewableIdpPartialController
  include RetrieveFederationDataPartialController

  # Validate the session manually within the action, as we don't want the normal 'no session' page.
  skip_before_action :validate_session, except: :resume
  skip_before_action :set_piwik_custom_variables, except: :resume
  layout 'slides', except: :index

  def index
    if session_is_valid?
      with_session
    elsif is_last_status?('PENDING')
      with_cookie
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

  def session_is_valid?
    session_validator.validate(cookies, session).ok? && session.key?(:selected_provider) && !selected_identity_provider.nil?
  end

  def get_idp_from_cookie
    last_idp_value = last_idp
    unless last_idp_value.nil?
      return retrieve_decorated_singleton_idp_array_by_entity_id(current_identity_providers_for_sign_in, last_idp_value).first
    end
  end

  def with_session
    set_transaction_from_session
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
    render :with_user_session
  end

  def with_cookie
    selected_rp = get_rp_details
    set_transaction_from_cookie(selected_rp)
    enabled_idp_list = get_idp_list(last_rp)
    idp = get_idp_choice(enabled_idp_list, last_idp)
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(idp)
    render :with_user_session
  end

  def set_transaction_from_session
    @transaction = {
      name: current_transaction.name,
      homepage: current_transaction_homepage
    }
  end

  def set_transaction_from_cookie(selected_rp)
    @transaction = {
      name: get_translated_service_name(selected_rp.simple_id),
      homepage: selected_rp.transaction_homepage
    }
  end

  def get_rp_details
    last_rp_value = last_rp
    return nil if last_rp_value.nil?
    CONFIG_PROXY.get_transaction_details(last_rp_value)
  end

  def get_translated_service_name(simple_id)
    CONFIG_PROXY.get_transaction_translations(simple_id, params[:locale]).fetch(:name, nil)
  end

  def get_idp_list(transaction_id)
    list = CONFIG_PROXY.get_idp_list_for_sign_in(transaction_id)
    return nil if list.nil?
    list.idps
  end
end
