require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the response processing page' do
  before(:each) do
    set_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'should show the user the rp name and a spinner' do
    stub_matching_outcome
    visit '/response-processing'
    expect(page).to have_content I18n.t('hub.response_processing.heading', rp_name: 'Test RP')
    expect(page).to have_css('img.loading')
  end

  it 'redirects to start page when response is GOTO_HUB_LANDING_PAGE' do
    stub_matching_outcome(MatchingOutcomeResponse::GOTO_HUB_LANDING_PAGE)
    visit '/response-processing'
    expect(page).to have_current_path('/start')
  end

  it 'redirects to signing in page when response is SEND_NO_MATCH_RESPONSE_TO_TRANSACTION' do
    stub_matching_outcome(MatchingOutcomeResponse::SEND_NO_MATCH_RESPONSE_TO_TRANSACTION)
    visit '/response-processing'
    expect(page).to have_current_path('/redirect-to-service/signing-in')
  end

  it 'redirects to signing in page when response is SEND_SUCCESSFUL_MATCH_RESPONSE_TO_TRANSACTION' do
    stub_matching_outcome(MatchingOutcomeResponse::SEND_SUCCESSFUL_MATCH_RESPONSE_TO_TRANSACTION)
    visit '/response-processing'
    expect(page).to have_current_path('/redirect-to-service/signing-in')
  end

  it 'redirects to signing in page when response is SEND_USER_ACCOUNT_CREATED_RESPONSE_TO_TRANSACTION' do
    stub_matching_outcome(MatchingOutcomeResponse::SEND_USER_ACCOUNT_CREATED_RESPONSE_TO_TRANSACTION)
    visit '/response-processing'
    expect(page).to have_current_path('/redirect-to-service/signing-in')
  end

  it 'redirects to further information page when response is GET_C3_DATA' do
    stub_matching_outcome(MatchingOutcomeResponse::GET_C3_DATA)
    visit '/response-processing'
    expect(page).to have_current_path('/further-information')
  end

  it 'shows a matching error on the response processing page when there is a matching error' do
    stub_matching_outcome(MatchingOutcomeResponse::SHOW_MATCHING_ERROR_PAGE)
    visit '/response-processing'
    expect(page).to have_current_path('/response-processing')
    expect(page).to have_content(I18n.t('hub.response_processing.matching_error.problem', rp_name: 'Test RP'))
    expect(page).to have_link(I18n.t('hub.response_processing.matching_error.start_again_link'), href: redirect_to_service_error_path)
    expect(page).to have_css('h2',
      text: I18n.t('hub.other_ways_heading', other_ways_description: I18n.t('rps.test-rp.other_ways_description')))
    expect_feedback_source_to_be(page, 'MATCHING_ERROR_PAGE')
    expect(page).to have_title('Something went wrong - GOV.UK Verify - GOV.UK')
  end
end
