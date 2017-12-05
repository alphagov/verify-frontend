require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe CleverQuestions::StartController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
  end

  it 'renders LOA2 start page if service is level 2' do
    stub_piwik_request = stub_piwik_request_with_rp_and_loa('action_name' => 'The user has reached the start page')
    get :index, params: { locale: 'en' }
    expect(stub_piwik_request).to have_been_made.once
    expect(subject).to render_template(:start)
  end

  it 'will redirect to sign in page' do
    stub_piwik_request = stub_piwik_journey_type_request(
      'SIGN_IN',
      'The user started a sign-in journey',
      'LEVEL_2'
    )
    get :sign_in, params: { locale: 'en' }
    expect(subject).to redirect_to('/sign-in')
    expect(stub_piwik_request).to have_been_made.once
  end

  it 'will redirect to will it work for me page' do
    stub_piwik_request = stub_piwik_journey_type_request(
      'REGISTRATION',
      'The user started a registration journey',
      'LEVEL_2'
    )
    get :register, params: { locale: 'en' }
    expect(subject).to redirect_to('/will-it-work-for-me')
    expect(stub_piwik_request).to have_been_made.once
  end
end
