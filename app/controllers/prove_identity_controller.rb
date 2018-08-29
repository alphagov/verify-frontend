class ProveIdentityController < ApplicationController
  def index
    render :prove_identity
  end

  def retry_eidas_journey
    POLICY_PROXY.restart_eidas_journey(session[:verify_session_id])
    redirect_to prove_identity_path
  end
end
