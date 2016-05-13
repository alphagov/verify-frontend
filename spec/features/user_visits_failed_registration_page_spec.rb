require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the failed registration page' do
  before(:each) do
    set_session_cookies!
  end

  it 'includes expected content' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
    )
    visit '/failed-registration'

    expect_feedback_source_to_be(page, 'FAILED_REGISTRATION_PAGE')
    expect(page).to have_content 'IDCorp was unable to verify your identity'
    expect(page).to have_content 'Contact IDCorp for more information'
    expect(page).to have_css 'strong', text: '100 IDCorp Lane'
  end

  it 'includes a link to try another idp' do
    restart_request = stub_request(:put, api_uri('session/state')).to_return(status: 200)

    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
    )
    visit '/failed-registration'
    click_button 'Try another certified company'

    expect(page).to have_current_path(select_documents_path)
    expect(restart_request).to have_been_made.once
  end
end
