require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When user visits the confirmation page' do
  before(:each) do
    page.set_rack_session(
      selected_idp_was_recommended: true,
      transaction_simple_id: 'test-rp'
    )
    set_selected_idp_in_session(entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one')
    set_session_and_session_cookies!
    stub_api_idp_list_for_loa
    stub_policy
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
    stub_transactions_list
    visit '/confirmation'
    click_button t('navigation.continue')
    # TODO - make this not rubbish
    expect(page).to have_current_path(response_processing_path + "/response-processing")
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

  it 'saves a remember-idp cookie when the check box is ticked by default' do
    stub_matching_outcome
    set_journey_hint_cookie('entity-id')

    visit '/confirmation'
    click_button "Continue"
    visit '/confirmation'
    journey_hint_cookie.encrypted["entity-id"] = "foobar"

  end

  it 'does not save a remember-idp cookie when the check box is unticked' do
    stub_matching_outcome
    visit '/confirmation'
    uncheck "remember-idp"
    click_button "Continue"
    visit '/confirmation'
    Capybara.current_session.driver.request.cookies.[]('verify-front-journey-hint').should be_nil
  end

  it 'clears an existing remember-idp cookie if the check box is unticked' do
    set_journey_hint_cookie('entity-id')

    stub_matching_outcome
    visit '/confirmation'
    uncheck "remember-idp"
    click_button "Continue"
    Capybara.current_session.driver.request.cookies.[]('verify-front-journey-hint').should be_nil
  end

  it 'changes the existing value of the stored cookie when different idp is used' do
    stub_matching_outcome
    visit '/confirmation'
    check "remember-idp"
    click_button "Continue"
    Capybara.current_session.driver.request.cookies.[]('verify-front-journey-hint').should be_nil
  end

  def journey_hint_cookie
    ActionDispatch::Cookies::CookieJar.build(Capybara.current_session.driver.request, nil)
  end
end
