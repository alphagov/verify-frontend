require 'rails_helper'
require 'controller_helper'
require 'authn_response_examples'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe AuthnResponseController do
  context 'idp' do
    context 'registration' do
      include_examples 'idp_authn_response', 'registration', 'SUCCESS', 'Success - REGISTER_WITH_IDP at LOA LEVEL_1', :confirmation_path
      include_examples 'idp_authn_response', 'registration', 'CANCEL', 'Cancel - REGISTER_WITH_IDP', :cancelled_registration_path
      include_examples 'idp_authn_response', 'registration', 'FAILED_UPLIFT', 'Failed Uplift - REGISTER_WITH_IDP', :failed_uplift_path
      include_examples 'idp_authn_response', 'registration', 'PENDING', 'Paused - REGISTER_WITH_IDP', :paused_registration_path
      include_examples 'idp_authn_response', 'registration', 'OTHER', 'Failure - REGISTER_WITH_IDP', :failed_registration_path
    end

    context 'sign_in' do
      include_examples 'idp_authn_response', 'sign_in', 'SUCCESS', 'Success - SIGN_IN_WITH_IDP at LOA LEVEL_1', :response_processing_path
      include_examples 'idp_authn_response', 'sign_in', 'CANCEL', 'Cancel - SIGN_IN_WITH_IDP', :start_path
      include_examples 'idp_authn_response', 'sign_in', 'FAILED_UPLIFT', 'Failed Uplift - SIGN_IN_WITH_IDP', :failed_uplift_path
      include_examples 'idp_authn_response', 'sign_in', 'PENDING', 'Paused - SIGN_IN_WITH_IDP', :paused_registration_path
      include_examples 'idp_authn_response', 'sign_in', 'OTHER', 'Failure - SIGN_IN_WITH_IDP', :failed_sign_in_path
    end

    it 'when relay state does not equal session id in the idp response' do
      set_session_and_cookies_with_loa('LEVEL_1')
      session[:verify_session_id] = 'non-existent'

      post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }

      expect(subject).to render_template(:something_went_wrong)
    end
  end

  context 'country' do
    context 'registration' do
      include_examples 'country_authn_response', 'registration', 'SUCCESS', :confirmation_path
      include_examples 'country_authn_response', 'registration', 'CANCEL', :failed_registration_path
      include_examples 'country_authn_response', 'registration', 'FAILED_UPLIFT', :failed_uplift_path
      include_examples 'country_authn_response', 'registration', 'OTHER', :failed_registration_path
    end

    context 'sign_in' do
      include_examples 'country_authn_response', 'sign_in', 'SUCCESS', :response_processing_path
      include_examples 'country_authn_response', 'sign_in', 'CANCEL', :start_path
      include_examples 'country_authn_response', 'sign_in', 'FAILED_UPLIFT', :failed_uplift_path
      include_examples 'country_authn_response', 'sign_in', 'OTHER', :failed_sign_in_path
    end

    it 'when relay state does not equal session id in the country response' do
      set_session_and_cookies_with_loa('LEVEL_1')
      session[:verify_session_id] = 'non-existent'

      post :country_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }

      expect(subject).to render_template(:something_went_wrong)
    end
  end

  describe 'idp tracking cookie' do
    let(:saml_proxy_api) { double(:saml_proxy_api) }
    let(:idp_authn_response) { IdpAuthnResponse.new(
      'result' => status,
      'isRegistration' => 'registration',
      'loaAchieved' => 'LEVEL_1'
    ) }
    let(:selected_idp) { {
      'entity_id' => 'http://idcorp.com',
      'simple_id' => 'stub-idp-one',
      'levels_of_assurance' => %w(LEVEL_1 LEVEL_2)
    } }
    let(:status) { 'SUCCESS' }
    let(:expected_cookie) { {
      entity_id: 'http://idcorp.com',
      simple_id: 'stub-idp-one',
      levels_of_assurance: %w(LEVEL_1 LEVEL_2),
      SUCCESS: 'http://idcorp.com'
    } }

    before(:each) do
      stub_const('SAML_PROXY_API', saml_proxy_api)
      set_session_and_cookies_with_loa('LEVEL_1')
      allow(saml_proxy_api).to receive(:idp_authn_response).and_return(idp_authn_response)
      stub_piwik_request_with_rp_and_loa({}, 'LEVEL_1')
      session[:selected_idp] = selected_idp
    end

    subject(:cookie_after_request) do
      post :idp_response, params: { RelayState: 'my-session-id-cookie', SAMLResponse: 'a-saml-response', locale: 'en' }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]
    end

    context 'with no selected idp' do
      let(:selected_idp) { nil }
      it { should be_nil }
    end

    context 'receiving SUCCESS without previous cookie' do
      let(:expected_cookie) { { SUCCESS: 'http://idcorp.com' } }
      it('should add new success status') { should eq expected_cookie.to_json }
    end

    context 'receiving SUCCESS and has cookie with existing entity id' do
      let!(:existing_cookie) {
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
          'entity_id' => 'http://idcorp.com',
          'simple_id' => 'stub-idp-one',
          'levels_of_assurance' => %w(LEVEL_1 LEVEL_2)
        }.to_json
      }
      it('should not delete/overwrite previous entity_id') { should eq expected_cookie.to_json }
    end

    context 'receiving SUCCESS and has cookie with existing status' do
      let!(:existing_cookie) {
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
          'entity_id' => 'http://idcorp.com',
          'simple_id' => 'stub-idp-one',
          'levels_of_assurance' => %w(LEVEL_1 LEVEL_2),
          'SUCCESS' => 'http://old-idcorp.com'
        }.to_json
      }
      it('should update the existing status') { should eq(expected_cookie.to_json) }
    end

    context 'receiving PENDING and has cookie with existing status' do
      let(:status) { 'PENDING' }
      let(:expected_cookie) { {
        SUCCESS: 'http://success-idcorp.com',
        PENDING: 'http://idcorp.com'
      } }
      let!(:existing_cookie) {
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { 'SUCCESS' => 'http://success-idcorp.com' }.to_json
      }
      it('should add a new status') { should eq expected_cookie.to_json }
    end

    context 'receiving FAILED' do
      let(:status) { 'FAILED' }
      let(:expected_cookie) { { FAILED: 'http://idcorp.com' } }
      it('should add a new failure status with idp entity id') { should eq expected_cookie.to_json }
    end
  end
end
