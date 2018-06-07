require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe StartVariantController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
  end

  it 'renders LOA2 start page if service is level 2' do
    get :index, params: { locale: 'en' }
    expect(subject).to render_template(:start)
  end

  context 'when form is valid' do
    it 'will redirect to sign in page when selection is false' do
      stub_piwik_request = stub_piwik_journey_type_request(
        'SIGN_IN',
        'The user started a sign-in journey',
        'LEVEL_2'
      )
      post :request_post, params: { locale: 'en', start_form: { selection: false } }
      expect(subject).to redirect_to('/sign-in')
      expect(stub_piwik_request).to have_been_made.once
    end

    it 'will redirect to about-choosing-a-company page when selection is true' do
      stub_piwik_request = stub_piwik_journey_type_request(
        'REGISTRATION',
        'The user started a registration journey',
        'LEVEL_2'
      )
      post :request_post, params: { locale: 'en', start_form: { selection: true } }
      expect(subject).to redirect_to('/about-choosing-a-company')
      expect(stub_piwik_request).to have_been_made.once
    end
  end

  context 'when form is invalid' do
    it 'renders itself' do
      post :request_post, params: { locale: 'en' }
      expect(subject).to render_template(:start)
      expect(flash[:errors]).not_to be_empty
    end
  end

  it 'will redirect to about-choosing-a-company page when selection is registration' do
    stub_piwik_request = stub_piwik_journey_type_request(
      'REGISTRATION',
      'The user started a registration journey',
      'LEVEL_2'
    )
    get :register, params: { locale: 'en' }
    expect(subject).to redirect_to('/about-choosing-a-company')
    expect(stub_piwik_request).to have_been_made.once
  end
end
