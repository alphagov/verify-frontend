require 'partials/journey_hinting_partial_controller'
require 'partials/viewable_idp_partial_controller'

class ProveIdentityController < ApplicationController
  include JourneyHintingPartialController
  include ViewableIdpPartialController

  def index
    journey_hint_entity_id = attempted_entity_id
    if journey_hint_entity_id.nil?
      render :prove_identity
    else
      @identity_providers = journey_hint_entity_id.nil? ? [] : retrieve_decorated_singleton_idp_array_by_entity_id(current_available_identity_providers_for_registration, journey_hint_entity_id)
      if @identity_providers.empty?
        return render :prove_identity
      end
      render 'shared/sign_in_hint'
    end
  end

  def retry_eidas_journey
    restart_journey if identity_provider_selected? && user_journey_type?(JourneyType::EIDAS)
    redirect_to prove_identity_path
  end
end
