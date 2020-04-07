require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When user visits the confirmation page' do
  before(:each) do
    page.set_rack_session(
      selected_idp_was_recommended: true,
      transaction_simple_id: 'test-rp'
    )
    set_session_and_session_cookies!
    set_selected_idp_in_session(entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one')
    stub_api_idp_list_for_registration
  end

  it 'includes the appropriate feedback source, title and content' do
    visit '/confirmation'
    expect(page).not_to have_link t('feedback_link.feedback_form')
    expect(page).to have_link t('hub.feedback.title'), href: '/feedback?feedback-source=CONFIRMATION_PAGE'
    expect(page).to have_title t('hub.confirmation.title')
    expect(page).to have_text t('hub.confirmation.message', display_name: 'IDCorp')
    expect(page).to have_text t('hub.confirmation.continue_to_rp', transaction_name: 'test GOV.UK Verify user journeys')
  end

  it 'displays the IDP name' do
    visit '/confirmation'
    expect(page).to have_text t('hub.confirmation.heading', display_name: 'IDCorp')
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
    click_link t('navigation.continue')
    expect(page).to have_current_path(response_processing_path)
  end

  it 'displays government services requiring extra security when LOA is level one' do
    stub_transactions_list
    set_loa_in_session('LEVEL_1')
    visit '/confirmation'
    expect(page).to have_text t('hub.confirmation.extra_security')
  end

  it 'does not display government services requiring extra security when LOA is level two' do
    stub_transactions_list
    set_loa_in_session('LEVEL_2')
    visit '/confirmation'
    expect(page).not_to have_text t('hub.confirmation.extra_security')
  end
end
