require "partials/journey_hinting_partial_controller"

class ProveIdentityController < ApplicationController
  include JourneyHintingPartialController

  def index
    render :prove_identity unless try_render_journey_hint
  end

  def ignore_hint
    remove_hint_and_report
    redirect_to prove_identity_path
  end

  def retry_eidas_journey
    restart_journey if identity_provider_selected? && user_journey_type?(JourneyType::EIDAS)
    redirect_to prove_identity_path
  end
end
