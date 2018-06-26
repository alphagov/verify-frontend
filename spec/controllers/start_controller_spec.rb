require 'rails_helper'
require 'application_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe StartController do
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

    it 'will redirect to about page when selection is true' do
      stub_piwik_request = stub_piwik_journey_type_request(
        'REGISTRATION',
        'The user started a registration journey',
        'LEVEL_2'
      )
      post :request_post, params: { locale: 'en', start_form: { selection: true } }
      expect(subject).to redirect_to('/about')
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

  it 'will redirect to about page when selection is registration' do
    stub_piwik_request = stub_piwik_journey_type_request(
      'REGISTRATION',
      'The user started a registration journey',
      'LEVEL_2'
    )
    get :register, params: { locale: 'en' }
    expect(subject).to redirect_to('/about')
    expect(stub_piwik_request).to have_been_made.once
  end

  context 'when hint cookie is present' do
    before :each do
      stub_api_idp_list_for_sign_in([{  'simpleId' => 'stub-idp-one',
                                        'entityId' => 'http://idcorp.com',
                                        'levelsOfAssurance' => %w(LEVEL_1) }])
    end

    it 'will render start page with hint' do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: 'http://idcorp.com', SUCCESS: 'http://idcorp.com' }.to_json
      get :index, params: { locale: 'en' }
      expect(subject).to render_template(:start_with_hint)
    end

    it 'will render normal start page if the hint has non-existing IDP' do
      get :index, params: { locale: 'en' }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: 'http://idcorpzz.com', SUCCESS: 'http://idcorpzz.com' }.to_json
      expect(subject).to render_template(:start)
    end

    it 'will render normal start page if hint cookie is invalid/corrupted' do
      get :index, params: { locale: 'en' }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { blah: 'nothing here' }.to_json
      expect(subject).to render_template(:start)
    end
  end
end
