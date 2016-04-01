require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the about certified companies page' do
  let(:simple_id) { 'stub-idp-one' }
  let(:idp_entity_id) { 'http://idcorp.com' }

  before(:each) do
    body = { 'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idpcorp.com' }], 'transactionEntityId' => 'some-id' }
    stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
    stub_transactions_list
    set_session_cookies!
  end

  it 'includes the appropriate feedback source' do
    visit '/about-certified-companies'

    expect_feedback_source_to_be(page, 'ABOUT_CERTIFIED_COMPANIES_PAGE')
  end

  it 'displays content in Welsh', pending: true do
    visit '/am-gwmniau-ardystiedig'

    expect(page).to have_content 'Sut y gall cwmnïau wirio hunaniaeth'
    expect(page).to have_content 'Gall y cwmnïau hyn yn defnyddio eu data eu hunain'
  end

  it 'displays IdPs that are enabled' do
    visit '/about-certified-companies'

    expect(page).to have_css("img[src*='/white/#{simple_id}']")
  end

  it 'will show "How companies can verify identities" section' do
    visit '/about-certified-companies'

    expect(page).to have_content 'How companies can verify identities'
    expect(page).to have_content 'These companies can use their own data'
  end

  it 'will go to about identity accounts page when next is clicked' do
    visit '/about-certified-companies'
    click_link('Next')

    expect(page).to have_current_path('/about-identity-accounts')
  end
end
