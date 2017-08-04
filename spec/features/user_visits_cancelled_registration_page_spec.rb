require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'When user visits cancelled registration page' do
  before :each do
    set_session_and_session_cookies!
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      transaction_simple_id: 'test-rp'
    )
  end

  it 'will render itself' do
    visit('/cancelled-registration')

    expect(page).to have_title I18n.t('hub.cancelled_registration.title')
  end

  it 'will render other ways page when user clicks other ways link' do
    visit('/cancelled-registration')

    click_link 'Find out the other ways to register for an identity profile'
    expect(page).to have_current_path(other_ways_to_access_service_path)
  end

  it 'will render idp picker page when user clicks verify with another company' do
    stub_api_idp_list

    visit('/cancelled-registration')

    click_link 'Verify with another certified company'
    expect(page).to have_current_path(choose_a_certified_company_path)
  end

  it 'will render photo identity documents page when user clicks verify using other documents link' do
    visit('/cancelled-registration')

    click_link 'Verify using other documents'
    expect(page).to have_current_path(select_documents_path)
  end

  it 'will render feedback page when user clicks contact gov uk verify' do
    visit('/cancelled-registration')

    click_link 'Contact GOV.UK Verify'
    expect(page).to have_current_path(feedback_path)
  end
end
