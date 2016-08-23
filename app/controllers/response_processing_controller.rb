class ResponseProcessingController < ApplicationController
  before_action :hide_available_languages

  def index
    @rp_name = current_transaction.rp_name
    outcome = SESSION_PROXY.matching_outcome(session['verify_session_id'])
    case outcome
    when MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE
      report_to_analytics('Matching Outcome - Hub Landing')
      redirect_to start_path
    when MatchingOutcomeResponse::SEND_NO_MATCH_RESPONSE_TO_TRANSACTION
      report_to_analytics('Matching Outcome - No Match')
      redirect_to redirect_to_service_signing_in_path
    when MatchingOutcomeResponse::SEND_SUCCESSFUL_MATCH_RESPONSE_TO_TRANSACTION
      report_to_analytics('Matching Outcome - Match')
      redirect_to redirect_to_service_signing_in_path
    when MatchingOutcomeResponse::SEND_USER_ACCOUNT_CREATED_RESPONSE_TO_TRANSACTION
      report_to_analytics('Unknown User Outcome - Account Created')
      redirect_to redirect_to_service_signing_in_path
    when MatchingOutcomeResponse::GET_C3_DATA
      report_to_analytics('Matching Outcome - Cycle3')
      redirect_to further_information_path
    when MatchingOutcomeResponse::SHOW_MATCHING_ERROR_PAGE
      report_to_analytics('Matching Outcome - Error')
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
