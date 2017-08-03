require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'When user visits cancelled registration page' do
  before :each do
    set_session_and_session_cookies!
  end

  it 'will render itself' do
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
    )
    visit('/cancelled-registration')

    expect(page).to have_title I18n.t('hub.cancelled_registration.title')
  end

  it 'will render other ways page when user clicks other ways link' do
    page.set_rack_session(
        selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
        transaction_simple_id: 'test-rp'
    )
    visit('/cancelled-registration')

    click_link 'Find out the other ways to register for an identity profile'
    expect(page).to have_current_path(other_ways_to_access_service_path)
  end
end
