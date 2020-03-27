require 'partials/journey_hinting_partial_controller'
require 'partials/viewable_idp_partial_controller'
require 'partials/user_cookies_partial_controller'

class ProveIdentityController < ApplicationController
  include JourneyHintingPartialController
  include ViewableIdpPartialController
  include UserCookiesPartialController

  def index
    journey_hint_entity_id = success_entity_id
    if journey_hint_entity_id.nil?
      render :prove_identity
    else
      @identity_provider = retrieve_decorated_singleton_idp_array_by_entity_id(current_available_identity_providers_for_sign_in, journey_hint_entity_id).first
      if @identity_provider.nil?
        return render :prove_identity
      end

      render 'shared/sign_in_hint'
    end
  end

  def ignore_hint
    journey_hint_entity_id = success_entity_id
    remove_success_journey_hint
    idp = retrieve_decorated_singleton_idp_array_by_entity_id(current_available_identity_providers_for_sign_in, journey_hint_entity_id).first unless journey_hint_entity_id.nil?
    unless idp.nil?
      FEDERATION_REPORTER.report_sign_in_journey_ignored(current_transaction, request, idp.display_name)
    end
    redirect_to prove_identity_path
  end

  def retry_eidas_journey
    restart_journey if identity_provider_selected? && user_journey_type?(JourneyType::EIDAS)
    redirect_to prove_identity_path
  end
end
