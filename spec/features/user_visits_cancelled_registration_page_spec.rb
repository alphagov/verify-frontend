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

  it 'the page is rendered with the correct links ' do
    visit('/cancelled-registration')

    expect(page).to have_title I18n.t('hub.cancelled_registration.title')
    expect(page).to have_link('Find out the other ways to register for an identity profile', href: other_ways_to_access_service_path)
    expect(page).to have_link(I18n.t('hub.cancelled_registration.options.verify_with_another_company'), href: choose_a_certified_company_path)
    expect(page).to have_link(I18n.t('hub.cancelled_registration.options.verify_using_other_documents'), href: select_documents_path)
    expect(page).to have_link(I18n.t('hub.cancelled_registration.options.contact_verify'), href: "#{feedback_path}?feedback-source=CANCELLED_REGISTRATION")
  end
end
