require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the failed sign in page' do
  before(:each) do
    set_session_cookies!
  end

  it 'includes expected content' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' })
    visit '/failed-sign-in'

    expect_feedback_source_to_be(page, 'FAILED_SIGN_IN_PAGE')
    expect(page).to have_title("#{I18n.t('hub.failed_sign_in.title')} - GOV.UK Verify - GOV.UK")
    expect(page).to have_content I18n.t('hub.failed_sign_in.heading', idp_name: 'IDCorp')
    expect(page).to have_content 'You may have selected the wrong company. Check your emails and text messages for confirmation of who verified you.'
    expect(page).to have_link(I18n.t('hub.failed_sign_in.start_again'), href: start_path)
  end
end
