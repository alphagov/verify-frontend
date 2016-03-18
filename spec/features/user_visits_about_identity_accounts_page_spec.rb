require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the about certified companies page' do
  let(:simple_id) { 'stub-idp-one'}
  let(:idp_entity_id) { 'http://idcorp.com' }

  before(:each) do
    stub_request(:get, api_uri('session/idps')).to_return(body: [{'simpleId' => simple_id, 'entityId' => idp_entity_id}].to_json)
    set_session_cookies!
  end

  it 'includes the appropriate feedback source' do
    visit '/about-identity-accounts'

    expect_feedback_source_to_be(page, 'ABOUT_IDENTITY_ACCOUNTS_PAGE')
  end

  it 'displays content in Welsh' do
    visit '/am-hunaniaeth-cyfrifon'

    expect(page).to have_content 'Dilysu eich hunaniaeth yn cymryd tua 10 munud.'
  end
end
