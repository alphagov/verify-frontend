require 'rails_helper'
require 'controller_helper'
require 'support/authn_response_examples'
require 'tracking_cookie_examples'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe AuthnResponseController do
  context 'idp' do
    context 'registration' do
      include_examples 'idp_authn_response', 'registration', 'SUCCESS', 'Success - REGISTER_WITH_IDP at LOA LEVEL_1', :confirmation_path, '2018-09-03T10:02:07.566Z'
      include_examples 'idp_authn_response', 'registration', 'MATCHING_JOURNEY_SUCCESS', 'Success Matching Journey - REGISTER_WITH_IDP at LOA LEVEL_1', :confirmation_path
      include_examples 'idp_authn_response', 'registration', 'NON_MATCHING_JOURNEY_SUCCESS', 'Success Non Matching Journey - REGISTER_WITH_IDP at LOA LEVEL_1', :confirmation_non_matching_journey_path
      include_examples 'idp_authn_response', 'registration', 'CANCEL', 'Cancel - REGISTER_WITH_IDP', :cancelled_registration_path
      include_examples 'idp_authn_response', 'registration', 'FAILED_UPLIFT', 'Failed Uplift - REGISTER_WITH_IDP', :failed_uplift_path
      include_examples 'idp_authn_response', 'registration', 'PENDING', 'Paused - REGISTER_WITH_IDP', :paused_registration_path
      include_examples 'idp_authn_response', 'registration', 'FAILED', 'Failure - REGISTER_WITH_IDP', :failed_registration_path
      include_examples 'idp_authn_response', 'registration', 'FAILED', 'Failure - REGISTER_WITH_IDP', :failed_registration_path, '2018-09-03T10:02:07.566Z'
    end

    context 'sign_in' do
      include_examples 'idp_authn_response', 'sign_in', 'SUCCESS', 'Success - SIGN_IN_WITH_IDP at LOA LEVEL_1', :response_processing_path, '2018-09-03T10:02:07.566Z'
      include_examples 'idp_authn_response', 'sign_in', 'MATCHING_JOURNEY_SUCCESS', 'Success Matching Journey - SIGN_IN_WITH_IDP at LOA LEVEL_1', :response_processing_path
      include_examples 'idp_authn_response', 'sign_in', 'NON_MATCHING_JOURNEY_SUCCESS', 'Success Non Matching Journey - SIGN_IN_WITH_IDP at LOA LEVEL_1', :redirect_to_service_signing_in_path
      include_examples 'idp_authn_response', 'sign_in', 'CANCEL', 'Cancel - SIGN_IN_WITH_IDP', :start_path
      include_examples 'idp_authn_response', 'sign_in', 'FAILED_UPLIFT', 'Failed Uplift - SIGN_IN_WITH_IDP', :failed_uplift_path
      include_examples 'idp_authn_response', 'sign_in', 'PENDING', 'Paused - SIGN_IN_WITH_IDP', :paused_registration_path
      include_examples 'idp_authn_response', 'sign_in', 'FAILED', 'Failure - SIGN_IN_WITH_IDP', :failed_sign_in_path
      include_examples 'idp_authn_response', 'sign_in', 'FAILED', 'Failure - SIGN_IN_WITH_IDP', :failed_sign_in_path, '2018-09-03T10:02:07.566Z'
    end

    context 'resuming' do
      include_examples 'idp_authn_response', 'resuming', 'SUCCESS', 'Success - RESUME_WITH_IDP at LOA LEVEL_1', :response_processing_path
      include_examples 'idp_authn_response', 'resuming', 'MATCHING_JOURNEY_SUCCESS', 'Success Matching Journey - RESUME_WITH_IDP at LOA LEVEL_1', :response_processing_path
      include_examples 'idp_authn_response', 'resuming', 'NON_MATCHING_JOURNEY_SUCCESS', 'Success Non Matching Journey - RESUME_WITH_IDP at LOA LEVEL_1', :redirect_to_service_signing_in_path
      include_examples 'idp_authn_response', 'resuming', 'CANCEL', 'Cancel - RESUME_WITH_IDP', :start_path
      include_examples 'idp_authn_response', 'resuming', 'FAILED_UPLIFT', 'Failed Uplift - RESUME_WITH_IDP', :failed_uplift_path
      include_examples 'idp_authn_response', 'resuming', 'PENDING', 'Paused - RESUME_WITH_IDP', :paused_registration_path
      include_examples 'idp_authn_response', 'resuming', 'FAILED', 'Failure - RESUME_WITH_IDP', :failed_sign_in_path
    end

    context 'single-idp' do
      include_examples 'idp_authn_response', 'single-idp', 'SUCCESS', 'Success - SINGLE_IDP at LOA LEVEL_1', :confirmation_path, '2018-09-03T10:02:07.566Z'
      include_examples 'idp_authn_response', 'single-idp', 'MATCHING_JOURNEY_SUCCESS', 'Success Matching Journey - SINGLE_IDP at LOA LEVEL_1', :confirmation_path
      include_examples 'idp_authn_response', 'single-idp', 'NON_MATCHING_JOURNEY_SUCCESS', 'Success Non Matching Journey - SINGLE_IDP at LOA LEVEL_1', :confirmation_non_matching_journey_path
      include_examples 'idp_authn_response', 'single-idp', 'CANCEL', 'Cancel - SINGLE_IDP', :start_path
      include_examples 'idp_authn_response', 'single-idp', 'FAILED_UPLIFT', 'Failed Uplift - SINGLE_IDP', :failed_uplift_path
      include_examples 'idp_authn_response', 'single-idp', 'PENDING', 'Paused - SINGLE_IDP', :paused_registration_path
      include_examples 'idp_authn_response', 'single-idp', 'FAILED', 'Failure - SINGLE_IDP', :failed_registration_path
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
      include_examples 'country_authn_response', 'registration', 'NON_MATCHING_JOURNEY_SUCCESS', :redirect_to_service_signing_in_path
      include_examples 'country_authn_response', 'registration', 'CANCEL', :failed_registration_path
      include_examples 'country_authn_response', 'registration', 'FAILED_UPLIFT', :failed_uplift_path
      include_examples 'country_authn_response', 'registration', 'FAILED', :failed_registration_path
    end

    context 'sign_in' do
      include_examples 'country_authn_response', 'sign_in', 'SUCCESS', :response_processing_path
      include_examples 'country_authn_response', 'sign_in', 'NON_MATCHING_JOURNEY_SUCCESS', :redirect_to_service_signing_in_path
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

    context 'receiving status with no single idp cookie set will not error' do
      let(:status) { 'PENDING' }
      let(:cookie_with_pending_status) {
        { STATE: { IDP: 'http://idcorp.com',
                   RP: 'http://www.test-rp.gov.uk/SAML2/MD',
                   STATUS: 'PENDING' } }.to_json
      }
      it { should eq cookie_with_pending_status }
      it { expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be_nil }
    end
  end
end
