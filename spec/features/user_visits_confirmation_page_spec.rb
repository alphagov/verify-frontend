require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When user visits the confirmation page' do
  let(:stub_session) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      transaction_simple_id: 'test-rp'
    )
  }

  before(:each) do
    stub_session
    set_session_and_session_cookies!
  end

  it 'includes the appropriate feedback source, title and content' do
    visit '/confirmation'
    expect_feedback_source_to_be(page, 'CONFIRMATION_PAGE')
    expect(page).to have_title("#{I18n.t('hub.confirmation.title')} - GOV.UK Verify - GOV.UK")
    expect(page).to have_text(I18n.t('hub.confirmation.message'))
    expect(page).to have_text(I18n.t('hub.confirmation.continue_to_rp', transaction_name: 'register for an identity profile'))
  end

  it 'displays the IDP name' do
    visit '/confirmation'
    expect(page).to have_text(I18n.t('hub.confirmation.heading', display_name: 'IDCorp'))
  end

  it 'displays the page in Welsh' do
    visit '/cadarnhad'
    expect(page).to have_css('html[lang=cy]')
  end

  it 'displays the page in English' do
    visit '/confirmation'
    expect(page).to have_css('html[lang=en]')
  end

  it 'sends user to response-processing page when they click the link' do
    stub_matching_outcome
    visit '/confirmation'
    click_link I18n.t('navigation.continue')
    expect(page).to have_current_path(response_processing_path)
  end
end
