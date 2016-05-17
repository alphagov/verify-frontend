require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the failed registration page' do
  before(:each) do
    set_session_cookies!
  end

  it 'includes expected content' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      transaction_simple_id: 'test-rp'
    )
    visit '/failed-registration'

    expect_feedback_source_to_be(page, 'FAILED_REGISTRATION_PAGE')
    expect(page).to have_content 'IDCorp was unable to verify your identity'
    expect(page).to have_content 'There are a few reasons'
    expect(page).to have_content 'Contact IDCorp for more information'
    expect(page).to have_css 'strong', text: '100 IDCorp Lane'
    expect(page).to have_link(
      'Other ways to access register for an identity profile',
      href: other_ways_to_access_service_path
    )
  end

  it 'includes a link to try another idp' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      transaction_simple_id: 'test-rp'
    )

    visit '/failed-registration'
    click_link 'Try another certified company'

    expect(page).to have_current_path(select_documents_path)
  end
end
