require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe StartVariantController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  it 'renders LOA1 start page if service is level 1' do
    # stub_piwik_request = stub_piwik_request_with_rp_and_loa({ 'action_name' => 'The user has reached the start page' }, 'LEVEL_1')
    get :index, params: { locale: 'en' }
    # expect(stub_piwik_request).to have_been_made.once
    expect(subject).to render_template(:start)
  end

  it 'will redirect to choose a certified company page when clicked on Register button and report to piwik' do
    stub_piwik_request = stub_piwik_journey_type_request(
      'REGISTRATION',
      'The user started a registration journey',
      'LEVEL_1'
    )
    get :register, params: { locale: 'en' }
    expect(subject).to redirect_to('/choose-a-certified-company')
    expect(stub_piwik_request).to have_been_made.once
  end

  it 'will redirect to sign-in page when clicked on sign in link and report to piwik' do
    stub_piwik_request = stub_piwik_journey_type_request(
      'SIGN_IN',
      'The user started a sign-in journey',
      'LEVEL_1'
    )
    get :sign_in, params: { locale: 'en' }
    expect(subject).to redirect_to('/sign-in')
    expect(stub_piwik_request).to have_been_made.once
  end
end
