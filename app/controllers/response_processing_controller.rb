class ResponseProcessingController < ApplicationController
  def index
    @rp_name = current_transaction.rp_name
    outcome = SESSION_PROXY.matching_outcome(cookies)
    case outcome
    when MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE
      redirect_to start_path
    when MatchingOutcomeResponse::WAIT
      render
    else
      something_went_wrong("Unknown matching response #{outcome.inspect}")
    end
  end
end
