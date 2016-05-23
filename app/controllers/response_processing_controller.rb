class ResponseProcessingController < ApplicationController
  def index
    @rp_name = current_transaction.rp_name
    outcome = SESSION_PROXY.matching_outcome(cookies)
    case outcome
    when MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE
      redirect_to start_path
    when MatchingOutcomeResponse::SEND_NO_MATCH_RESPONSE_TO_TRANSACTION
      redirect_to redirect_signing_in_path
    when MatchingOutcomeResponse::SEND_SUCCESSFUL_MATCH_RESPONSE_TO_TRANSACTION
      redirect_to redirect_signing_in_path
    when MatchingOutcomeResponse::SEND_USER_ACCOUNT_CREATED_RESPONSE_TO_TRANSACTION
      redirect_to redirect_signing_in_path
    when MatchingOutcomeResponse::GET_C3_DATA
      redirect_to further_information_path
    when MatchingOutcomeResponse::SHOW_MATCHING_ERROR_PAGE
      @other_ways_description = current_transaction.other_ways_description
      @other_ways_text = current_transaction.other_ways_text
      render 'matching_error', status: 500
    when MatchingOutcomeResponse::WAIT
      render
    else
      something_went_wrong("Unknown matching response #{outcome.inspect}")
    end
  end
end
