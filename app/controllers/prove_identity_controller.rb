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
end
