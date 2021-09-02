require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "response_processing_examples"

describe ResponseProcessingController do
  before :each do
    # Necessary so that we can expect() on controller.render() for the matching errors
    allow(subject).to receive(:render).and_call_original
  end

  include_examples "response_processing", MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE, "Matching Outcome - Hub Landing", :start_path
  include_examples "response_processing",  MatchingOutcomeResponse::SEND_NO_MATCH_RESPONSE_TO_TRANSACTION, "Matching Outcome - No Match", :redirect_to_service_signing_in_path
  include_examples "response_processing",  MatchingOutcomeResponse::SEND_SUCCESSFUL_MATCH_RESPONSE_TO_TRANSACTION, "Matching Outcome - Match", :redirect_to_service_signing_in_path
  include_examples "response_processing",  MatchingOutcomeResponse::SEND_USER_ACCOUNT_CREATED_RESPONSE_TO_TRANSACTION, "Unknown User Outcome - Account Created", :redirect_to_service_signing_in_path
  include_examples "response_processing",  MatchingOutcomeResponse::GET_C3_DATA, "Matching Outcome - Cycle3", :further_information_path

  include_examples "response_processing_errors",  MatchingOutcomeResponse::SHOW_MATCHING_ERROR_PAGE, "Matching Outcome - Error", "MATCHING_ERROR_PAGE"
  include_examples "response_processing_errors",  MatchingOutcomeResponse::USER_ACCOUNT_CREATION_FAILED, "Unknown User Outcome - Account Creation Failed", "ACCOUNT_CREATION_FAILED_PAGE"

  it "renders index when matching outcome response is wait" do
    set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)
    stub_matching_outcome(MatchingOutcomeResponse::WAIT)
    expect(subject).to render_template(nil)
    get :index, params: { locale: "en" }
  end

  it "raises error exception" do
    set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)
    allow(POLICY_PROXY).to receive(:matching_outcome).with(anything).and_return("SOMETHING")
    expect(subject).to receive(:something_went_wrong).with('Unknown matching response "SOMETHING"')
    get :index, params: { locale: "en" }
  end

  it "renders error text when the request is not proccesable" do
    request.headers["ACCEPT"] = "image/*"
    expect(Rails.logger).to receive(:warn).with("Received a request with unexpected accept headers - #{request.headers['ACCEPT']}")
    get :index, params: { locale: "en" }
    expect(response).to have_http_status :not_acceptable
    expect(response.body).to eq "Unable to serve the requested format"
  end
end
