require 'partials/viewable_idp_partial_controller'
require 'partials/journey_hinting_partial_controller'

class ConfirmYourIdentityController < ApplicationController
  include ViewableIdpPartialController
  include JourneyHintingPartialController

  def index
    journey_hint_entity_id = attempted_entity_id

    if journey_hint_entity_id.nil?
      cookie_error('missing verify-front-journey-hint')
    else
      @transaction_name = current_transaction.name
      @identity_providers = journey_hint_entity_id.nil? ? [] : retrieve_decorated_singleton_idp_array_by_entity_id(current_available_identity_providers_for_registration, journey_hint_entity_id)

      if @identity_providers.empty?
        cookie_error("invalid verify-front-journey-hint entity-id #{journey_hint_entity_id}")
      end
    end
  end

private

  def cookie_error(string)
    Rails.logger.warn(string)
    cookies.delete(CookieNames::VERIFY_FRONT_JOURNEY_HINT)
    redirect_to sign_in_path
  end
end
