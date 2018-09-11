require 'rails_helper'
require 'controller_helper'
require 'authn_response_examples'
require 'tracking_cookie_examples'
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
      include_examples 'idp_authn_response', 'registration', 'FAILED', 'Failure - REGISTER_WITH_IDP', :failed_registration_path
    end

    context 'sign_in' do
      include_examples 'idp_authn_response', 'sign_in', 'SUCCESS', 'Success - SIGN_IN_WITH_IDP at LOA LEVEL_1', :response_processing_path
      include_examples 'idp_authn_response', 'sign_in', 'CANCEL', 'Cancel - SIGN_IN_WITH_IDP', :start_path
      include_examples 'idp_authn_response', 'sign_in', 'FAILED_UPLIFT', 'Failed Uplift - SIGN_IN_WITH_IDP', :failed_uplift_path
      include_examples 'idp_authn_response', 'sign_in', 'PENDING', 'Paused - SIGN_IN_WITH_IDP', :paused_registration_path
      include_examples 'idp_authn_response', 'sign_in', 'FAILED', 'Failure - SIGN_IN_WITH_IDP', :failed_sign_in_path
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
      include_examples 'country_authn_response', 'registration', 'FAILED', :failed_registration_path
    end

    context 'sign_in' do
      include_examples 'country_authn_response', 'sign_in', 'SUCCESS', :response_processing_path
      include_examples 'country_authn_response', 'sign_in', 'CANCEL', :start_path
      include_examples 'country_authn_response', 'sign_in', 'FAILED_UPLIFT', :failed_uplift_path
      include_examples 'country_authn_response', 'sign_in', 'FAILED', :failed_country_sign_in_path
    end

    it 'when relay state does not equal session id in the country response' do
      set_session_and_cookies_with_loa('LEVEL_1')
      session[:verify_session_id] = 'non-existent'

      post :country_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }

      expect(subject).to render_template(:something_went_wrong)
    end
  end

  describe 'country tracking cookie' do
    let(:country_authn_response) {
      CountryAuthnResponse.new(
        'result' => status,
        'isRegistration' => 'registration',
        'loaAchieved' => 'LEVEL_1'
      )
    }
    let(:selected_entity) {
      {
        'entity_id' => 'https://acme.de/ServiceMetadata',
        'simple_id' => 'DE',
        'levels_of_assurance' => %w[LEVEL_1 LEVEL_2]
      }
    }

    let(:saml_proxy_api) { double(:saml_proxy_api) }

    before(:each) do
      stub_const('SAML_PROXY_API', saml_proxy_api)
      set_session_and_cookies_with_loa('LEVEL_1')
      stub_piwik_request_with_rp_and_loa({}, 'LEVEL_1')
      allow(saml_proxy_api).to receive(:forward_country_authn_response).and_return(country_authn_response)
      set_selected_country(selected_entity)
    end

    subject(:cookie_after_request) do
      post :country_response, params: { RelayState: 'my-session-id-cookie', SAMLResponse: 'a-saml-response', locale: 'en' }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]
    end

    %w[CANCEL FAILED_UPLIFT SUCCESS FAILED].each do |status|
      context "receiving #{status} status" do
        let(:status) { status }
        it { should be_nil }
      end
    end
  end

  describe 'idp tracking cookie' do
    let(:idp_authn_response) {
      IdpAuthnResponse.new(
        'result' => status,
        'isRegistration' => 'registration',
        'loaAchieved' => 'LEVEL_1'
      )
    }
    let(:post_endpoint) { :idp_response }
    let(:selected_entity) {
      {
        'entity_id' => 'http://idcorp.com',
        'simple_id' => 'stub-entity-one',
        'levels_of_assurance' => %w(LEVEL_1 LEVEL_2)
      }
    }
    before(:each) do
      allow(saml_proxy_api).to receive(:idp_authn_response).and_return(idp_authn_response)
      set_selected_idp(selected_entity)
    end

    include_examples 'tracking cookie'

    context 'receiving OTHER status' do
      let(:status) { 'OTHER' }
      let(:cookie_with_failed_status) {
        { STATE: { IDP: 'http://idcorp.com',
                   RP: 'http://www.test-rp.gov.uk/SAML2/MD',
                   STATUS: 'FAILED' } }.to_json
      }
      it { should eq cookie_with_failed_status }
    end

    context 'receiving PENDING status' do
      let(:status) { 'PENDING' }
      let(:cookie_with_pending_status) {
        { STATE: { IDP: 'http://idcorp.com',
                   RP: 'http://www.test-rp.gov.uk/SAML2/MD',
                   STATUS: 'PENDING' } }.to_json
      }
      it { should eq cookie_with_pending_status }
    end
  end
end
