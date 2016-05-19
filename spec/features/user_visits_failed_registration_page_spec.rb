require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the failed registration page' do
  before(:each) do
    set_session_cookies!
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      transaction_simple_id: 'test-rp'
    )
  end

  it 'includes expected content' do
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
    expect(page).to have_link('Try another certified company', href: select_documents_path)
  end

  it 'displays the content in Welsh' do
    visit '/failed-registration-cy'

    expect(page).to have_css 'html[lang=cy]'
  end
end
