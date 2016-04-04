require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the about page' do
  let(:transaction_entity_id) { 'some-id' }
  before(:each) do
    set_session_cookies!
    body = {
      'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idpcorp.com' }],
      'transactionSimpleId' => 'test-rp',
      'transactionEntityId' => transaction_entity_id
    }
    stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
  end

  it 'will include the appropriate feedback source' do
    visit '/about'

    expect_feedback_source_to_be(page, 'ABOUT_PAGE')
  end

  it 'will display the about page in Welsh', pending: true do
    visit '/am'
    expect(page).to have_content 'GOV.UK Verify yn gynllun i frwydro yn erbyn'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'will go to certified companies page when next is clicked' do
    visit '/about'
    expect(page).to have_content 'GOV.UK Verify is a scheme to fight the growing problem of online identity theft'
    click_link('Next')
    expect(page).to have_current_path('/about-certified-companies')

    piwik_request = {
        '_cvar' => "{\"1\":[\"RP\",\"analytics description for test-rp\"]}",
        'action_name' => 'The Yes option was selected on the start page',
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end
end
