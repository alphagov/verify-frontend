require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the about certified companies page' do
  let(:simple_id) { 'stub-idp-one'}
  let(:idp_entity_id) { 'http://idcorp.com' }

  it 'includes the appropriate feedback source' do
    stub_request(:get, api_uri('session/idps')).to_return(body: [{'simpleId' => simple_id, 'entityId' => idp_entity_id}].to_json)

    set_session_cookies!
    visit '/about-certified-companies'

    expect_feedback_source_to_be(page, 'ABOUT_CERTIFIED_COMPANIES_PAGE')
  end

  it 'displays IdPs that are available for registration' do
    stub_request(:get, api_uri('session/idps')).to_return(body: [{'simpleId' => simple_id, 'entityId' => idp_entity_id}].to_json)

    set_session_cookies!
    visit '/about-certified-companies'

    expect(page).to have_css("img[src*='#{simple_id}']")
  end
end
