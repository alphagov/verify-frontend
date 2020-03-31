class ProveIdentityController < ApplicationController
  def index
    render :prove_identity
  end

  def retry_eidas_journey
    restart_journey if identity_provider_selected? && user_journey_type?(JourneyType::EIDAS)
    redirect_to prove_identity_path
  end
end
