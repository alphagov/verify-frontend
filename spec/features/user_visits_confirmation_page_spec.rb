require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When user visits the confirmation page' do
  before(:each) do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      transaction_simple_id: 'test-rp'
    )
    set_session_and_session_cookies!
    stub_api_idp_list
  end

  it 'includes the appropriate feedback source, title and content' do
    visit '/confirmation'
    expect(page).not_to have_link I18n.t('feedback_link.feedback_form')
    expect(page).to have_link I18n.t('hub.feedback.title'), href: '/feedback?feedback-source=CONFIRMATION_PAGE'
    expect(page).to have_title("#{I18n.t('hub.confirmation.title')} - GOV.UK Verify - GOV.UK")
    expect(page).to have_text(I18n.t('hub.confirmation.message', display_name: 'IDCorp'))
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

  it 'displays government services requiring extra security when LOA is level one' do
    stub_transactions_list
    set_loa_in_session('LEVEL_1')
    visit '/confirmation'
    expect(page).to have_text(I18n.t('hub.confirmation.extra_security'))
  end

  it 'does not display government services requiring extra security when LOA is level two' do
    stub_transactions_list
    set_loa_in_session('LEVEL_2')
    visit '/confirmation'
    expect(page).not_to have_text(I18n.t('hub.confirmation.extra_security'))
  end
end
