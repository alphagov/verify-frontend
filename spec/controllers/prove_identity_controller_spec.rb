require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe ProveIdentityController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
  end

  it 'renders prove identity page' do
    get :index, params: { locale: 'en' }
    expect(subject).to render_template(:prove_identity)
  end

  context 'when restarting eIDAS journey' do
    let(:stub_restart_journey_request) { stub_restart_journey }

    it 'will not restart journey when it is not eIDAS' do
      set_selected_idp 'stub-idp'

      get :retry_eidas_journey, params: { locale: 'en' }

      expect(subject).to redirect_to(prove_identity_path)
      expect(stub_restart_journey_request).to have_not_been_made
    end

    it 'will restart journey when country selected' do
      set_selected_country 'stub-country'
      stub_restart_journey

      get :retry_eidas_journey, params: { locale: 'en' }

      expect(subject).to redirect_to(prove_identity_path)
      expect(stub_restart_journey_request).to have_been_made.once
      expect(session[:selected_provider]).to be_nil
    end
  end

  context 'when sign-in hint is present' do
    it 'renders the hint when IDP valid' do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        'ATTEMPT' => 'http://idcorp.com',
      }.to_json
      stub_api_idp_list_for_sign_in

      get :index, params: { locale: 'en' }
      expect(subject).to render_template('shared/sign_in_hint')
    end

    it 'renders the normal prove-identity page if IDP is invalid' do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        'ATTEMPT' => 'invalid',
      }.to_json
      stub_api_idp_list_for_sign_in

      get :index, params: { locale: 'en' }
      expect(subject).to render_template(:prove_identity)
    end

    it 'allows to disregard the hint and deletes the ATTEMPT' do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        'ATTEMPT' => 'http://idcorp.com',
        'SUCCESS' => 'http://some-entity-id'
      }.to_json

      get :ignore_hint, params: { locale: 'en' }

      cookie_hint = MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT])

      expect(subject).to render_template(:prove_identity)
      expect(cookie_hint['ATTEMPT']).to be_nil
      expect(cookie_hint['SUCCESS']).to eq 'http://some-entity-id'
    end
  end
end
