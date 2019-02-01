require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe SignInController do
  before(:each) do
    stub_api_idp_list_for_sign_in([{ 'simpleId' => 'stub-idp-one',
                                     'entityId' => 'http://idcorp.com',
                                     'levelsOfAssurance' => %w(LEVEL_1) },
                                   { 'simpleId' => 'stub-idp-two',
                                     'entityId' => 'http://idcorp-two.com',
                                     'levelsOfAssurance' => %w(LEVEL_1) },
                                   { 'simpleId' => 'stub-idp-broken',
                                     'entityId' => 'http://idcorp-broken.com',
                                     'levelsOfAssurance' => %w(LEVEL_1),
                                     'temporarilyUnavailable' => true }])
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  context '#index' do
    it 'will render the index page' do
      get :index, params: { locale: 'en' }
      expect(subject).to render_template(:index)
      expect(response).to have_http_status(:ok)
    end

    it 'will render the index page with invalid cookie' do
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: 'some-nonsense-idp-entity-id' }.to_json
      get :index, params: { locale: 'en' }
      expect(subject).to render_template(:index)
      expect(response).to have_http_status(:ok)
    end
  end

  context '#select_idp' do
    it 'will redirect to the path for the selected IDP' do
      stub_session_select_idp_request('http://idcorp.com')
      stub_piwik_request('action_name' => 'Sign In - IDCorp')

      post :select_idp, params: { locale: 'en', 'entity_id' => 'http://idcorp.com' }
      expect(session[:selected_provider].simple_id).to eq('stub-idp-one')
      expect(subject).to redirect_to(redirect_to_idp_sign_in_path)
    end

    it 'will redirect to an error page when the idp is unrecognised' do
      stub_session_select_idp_request('http://blah-de-blah.com')

      post :select_idp, params: { locale: 'en', 'entity_id' => 'http://blah-de-blah.com' }
      expect(response).to have_http_status(:not_found)
    end

    it 'will leave the session param nil if no journey hint was shown' do
      stub_session_select_idp_request('http://idcorp.com')
      stub_piwik_request('action_name' => 'Sign In - IDCorp')

      post :select_idp, params: { locale: 'en', 'entity_id' => 'http://idcorp.com' }
      expect(session[:user_followed_journey_hint]).to be_nil
    end

    it 'will have one temporarily unavailable IDP' do
      expect(subject.current_temporarily_unavailable_identity_providers_for_sign_in.length).to eq(1)
    end

    context 'with idp journey hint cookie' do
      before :each do
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { entity_id: 'http://idcorp.com', SUCCESS: 'http://idcorp.com' }.to_json
      end

      it 'will set the session param true if user followed the journey hint' do
        stub_session_select_idp_request('http://idcorp.com')
        stub_piwik_request('action_name' => 'Sign In - IDCorp')

        post :select_idp, params: { locale: 'en', 'entity_id' => 'http://idcorp.com' }
        expect(session[:user_followed_journey_hint]).to be true
      end

      it 'will set the session param false if user ignored the journey hint' do
        other_entity_id = 'http://idcorp-two.com'
        stub_session_select_idp_request(other_entity_id)
        stub_piwik_request('action_name' => 'Sign In - IDCorp')

        post :select_idp, params: { locale: 'en', 'entity_id' => other_entity_id }
        expect(session[:user_followed_journey_hint]).to be false
      end
    end
  end
end
