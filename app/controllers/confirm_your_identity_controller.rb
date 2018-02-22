require 'partials/viewable_idp_partial_controller'
require 'partials/journey_hinting_partial_controller'

class ConfirmYourIdentityController < ApplicationController
  include ViewableIdpPartialController
  include JourneyHintingPartialController

  def index
    journey_hint = journey_hint_value

    if journey_hint.nil?
      cookie_error('missing verify-front-journey-hint')
    else
      entity_id = journey_hint['entity_id']

      @transaction_name = current_transaction.name
      @identity_providers = entity_id.nil? ? [] : retrieve_decorated_singleton_idp_array_by_entity_id(current_identity_providers_for_loa, entity_id)

      if @identity_providers.empty?
        cookie_error("invalid verify-front-journey-hint entity-id #{entity_id}")
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
