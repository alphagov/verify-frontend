require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

describe PausedRegistrationController do
  let(:valid_rp) { 'test-rp-no-demo' }
  let(:valid_idp) { 'http://idcorp.com' }

  before(:each) do
    set_selected_idp('entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    set_session_and_cookies_with_loa('LEVEL_2', 'test-rp')
    stub_api_idp_list_for_sign_in
  end

  context 'user visits pause page' do
    subject { get :index, params: { locale: 'en' } }

    it 'renders paused registration page' do
      expect(subject).to render_template(:with_user_session)
    end

    it 'should render paused registration without session page when there is no idp selected' do
      session.delete(:selected_provider)

      expect(subject).to render_template(:without_user_session)
    end
  end

  context 'user is redirected to resume page' do
    subject { get :resume, params: { locale: 'en' } }

    it 'renders resume registration page if session present' do
      front_journey_hint_cookie = {
          STATE: {
              IDP: valid_idp,
              RP: valid_rp,
              STATUS: 'PENDING'
          }
      }

      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
      expect(subject).to render_template(:resume_with_idp)
    end

    it 'redirects to start page when invalid/disabled IDP present in cookie' do
      front_journey_hint_cookie = {
          STATE: {
              IDP: :'a-non-existent-idp-identifier',
              RP: :valid_rp,
              STATUS: 'PENDING'
          }
      }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
      expect(subject).to redirect_to start_path
    end

    it 'should render error page when user has no session' do
      session.clear

      expect(subject).to render_template(:something_went_wrong)
    end
  end
end
