require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the response processing page' do
  before(:each) do
    set_session_and_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'does not show language links' do
    stub_matching_outcome
    visit '/response-processing'
    expect(page).to_not have_link 'Cymraeg'
  end

  it 'should show the user the rp name and a spinner' do
    stub_matching_outcome
    visit '/response-processing'
    expect(page).to have_content t('hub.response_processing.heading', rp_name: 'Test RP')
    expect(page).to have_css('img.loading')
    expect(page).to have_css 'meta[http-equiv=refresh]', visible: false
  end

  it 'displays the content in Welsh' do
    stub_matching_outcome
    visit '/prosesu-ymateb'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'displays the error content in Welsh' do
    set_selected_idp_in_session(entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one')
    stub_matching_outcome MatchingOutcomeResponse::SHOW_MATCHING_ERROR_PAGE
    visit '/prosesu-ymateb'
    expect(page).to have_content 'Ceisiwch eto'
  end

  it 'should redirect to prove-identity page on matching error for an eIDAS journey' do
    set_selected_country_in_session(simple_id: 'stub-country')
    stub_matching_outcome MatchingOutcomeResponse::SHOW_MATCHING_ERROR_PAGE
    stub_restart_journey

    visit '/response-processing'
    click_on t('hub.response_processing.matching_error.online_link')

    expect(page).to have_current_path(prove_identity_path)
    expect(page.get_rack_session.key?('selected_provider')).to be_falsey
  end

  it 'should redirect to redirect-to-service page on matching error for a Verify (IDP) journey' do
    set_selected_idp_in_session(simple_id: 'stub-idp')
    stub_matching_outcome MatchingOutcomeResponse::SHOW_MATCHING_ERROR_PAGE

    visit '/response-processing'

    expect(page).to have_link t('hub.response_processing.matching_error.online_link'), href: redirect_to_service_error_path
  end
end
