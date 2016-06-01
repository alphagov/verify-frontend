require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the response processing page' do
  before(:each) do
    set_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  def stub_matching_report(outcome)
    stub_request(:get, INTERNAL_PIWIK.url)
      .with(query: hash_including('action_name' => "Matching Outcome - #{outcome}"))
  end

  def stub_unknown_user_report
    stub_request(:get, INTERNAL_PIWIK.url)
      .with(query: hash_including('action_name' => 'Unknown User Outcome - Account Created'))
  end

  it 'should show the user the rp name and a spinner' do
    stub_matching_outcome
    visit '/response-processing'
    expect(page).to have_content I18n.t('hub.response_processing.heading', rp_name: 'Test RP')
    expect(page).to have_css('img.loading')
    expect(page).to have_css 'meta[http-equiv=refresh]', visible: false
  end

  it 'redirects to start page when response is GOTO_HUB_LANDING_PAGE' do
    stub_matching_outcome(MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE)
    stubbed_request = stub_matching_report('Hub Landing')
    visit '/response-processing'
    expect(page).to have_current_path('/start')
    expect(stubbed_request).to have_been_made.once
  end

  it 'redirects to signing in page when response is SEND_NO_MATCH_RESPONSE_TO_TRANSACTION' do
    stub_response_for_rp
    stub_matching_outcome(MatchingOutcomeResponse::SEND_NO_MATCH_RESPONSE_TO_TRANSACTION)
    stubbed_report_request = stub_matching_report('No Match')
    visit '/response-processing'
    expect(page).to have_current_path('/redirect-to-service/signing-in')
    expect(stubbed_report_request).to have_been_made.once
  end

  it 'redirects to signing in page when response is SEND_SUCCESSFUL_MATCH_RESPONSE_TO_TRANSACTION' do
    stub_response_for_rp
    stub_matching_outcome(MatchingOutcomeResponse::SEND_SUCCESSFUL_MATCH_RESPONSE_TO_TRANSACTION)
    stubbed_report_request = stub_matching_report('Match')
    visit '/response-processing'
    expect(page).to have_current_path('/redirect-to-service/signing-in')
    expect(stubbed_report_request).to have_been_made.once
  end

  it 'redirects to signing in page when response is SEND_USER_ACCOUNT_CREATED_RESPONSE_TO_TRANSACTION' do
    stub_response_for_rp
    stubbed_report_request = stub_unknown_user_report
    stub_matching_outcome(MatchingOutcomeResponse::SEND_USER_ACCOUNT_CREATED_RESPONSE_TO_TRANSACTION)
    visit '/response-processing'
    expect(page).to have_current_path('/redirect-to-service/signing-in')
    expect(stubbed_report_request).to have_been_made.once
  end

  it 'redirects to further information page when response is GET_C3_DATA' do
    stub_matching_outcome(MatchingOutcomeResponse::GET_C3_DATA)
    stubbed_report_request = stub_matching_report('Cycle3')
    visit '/response-processing'
    expect(page).to have_current_path('/further-information')
    expect(stubbed_report_request).to have_been_made.once
  end

  it 'shows a matching error on the response processing page when there is a matching error' do
    stub_matching_outcome(MatchingOutcomeResponse::SHOW_MATCHING_ERROR_PAGE)
    stubbed_report_request = stub_matching_report('Error')
    visit '/response-processing'
    expect(page).to have_current_path('/response-processing')
    expect(page).to have_content(I18n.t('hub.response_processing.matching_error.problem', rp_name: 'Test RP'))
    expect(page).to have_link(I18n.t('hub.response_processing.matching_error.start_again_link'), href: redirect_to_service_error_path)
    expect(page).to have_css('h2',
      text: I18n.t('hub.other_ways_heading', other_ways_description: I18n.t('rps.test-rp.other_ways_description')))
    expect_feedback_source_to_be(page, 'MATCHING_ERROR_PAGE')
    expect(page).to have_title('Something went wrong - GOV.UK Verify - GOV.UK')
    expect(stubbed_report_request).to have_been_made.once
  end

  it 'displays the content in Welsh' do
    stub_matching_outcome
    visit '/response-processing-cy'
    expect(page).to have_css 'html[lang=cy]'
  end
end
