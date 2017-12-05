require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the failed sign in page' do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_loa
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' }
    )
  end

  it 'includes expected content' do
    visit '/failed-sign-in'

    expect_feedback_source_to_be(page, 'FAILED_SIGN_IN_PAGE', '/failed-sign-in')
    expect(page).to have_title("#{I18n.t('hub.failed_sign_in.title')} - GOV.UK Verify - GOV.UK")
    expect(page).to have_content I18n.t('hub.failed_sign_in.heading', display_name: 'IDCorp')
    expect(page).to have_content 'You may have selected the wrong company. Check your emails and text messages for confirmation of who verified you.'
    expect(page).to have_link(I18n.t('hub.failed_sign_in.start_again'), href: start_path)
  end

  it 'displays the content in Welsh' do
    visit '/mewngofnodi-wedi-methu'

    expect(page).to have_css 'html[lang=cy]'
  end
end
