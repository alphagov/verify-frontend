require 'rails_helper'
require 'controller_helper'
require 'authn_response_examples'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'

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

  context 'idp_cookie_tracking' do
    let(:saml_proxy_api) { double(:saml_proxy_api) }

    before(:each) do
      stub_const('SAML_PROXY_API', saml_proxy_api)
      set_session_and_cookies_with_loa('LEVEL_1')
    end

    def stub_saml_proxy_and_analytics(status, analytics_status)
      allow(saml_proxy_api).to receive(:idp_authn_response).and_return(IdpAuthnResponse.new('result' => status, 'isRegistration' => 'registration', 'loaAchieved' => 'LEVEL_1'))
      allow(subject).to receive(:report_to_analytics).with(analytics_status)
    end

    it 'should not set a cookie status if selected_idp is not in the session' do
      stub_saml_proxy_and_analytics('SUCCESS', 'Success - REGISTER_WITH_IDP at LOA LEVEL_1')
      post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
      expect(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]).to be_nil
    end

    it 'should add a new success status with idp entity id as a value to the journey hint cookie when response is SUCCESS' do
      expected_cookie = "{\"SUCCESS\":\"http://idcorp.com\"}"

      session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }

      stub_saml_proxy_and_analytics('SUCCESS', 'Success - REGISTER_WITH_IDP at LOA LEVEL_1')
      post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
      expect(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]).to eq(expected_cookie)
    end

    it 'should not delete/overwrite the entity_id of the existing journey hint cookie when adding a new status' do
      expected_cookie = "{" +
        "\"entity_id\":\"http://idcorp.com\"," +
        "\"simple_id\":\"stub-idp-one\"," +
        "\"levels_of_assurance\":[\"LEVEL_1\",\"LEVEL_2\"]," +
        "\"SUCCESS\":\"http://idcorp.com\"" +
        "}"

      session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }.to_json

      stub_saml_proxy_and_analytics('SUCCESS', 'Success - REGISTER_WITH_IDP at LOA LEVEL_1')
      post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
      expect(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]).to eq(expected_cookie)
    end

    it 'should update the existing status with a new entity id' do
      expected_cookie = "{" +
        "\"entity_id\":\"http://idcorp.com\"," +
        "\"simple_id\":\"stub-idp-one\"," +
        "\"levels_of_assurance\":[\"LEVEL_1\",\"LEVEL_2\"]," +
        "\"SUCCESS\":\"http://idcorp.com\"" +
        "}"

      session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2), 'SUCCESS' => 'http://old-idcorp.com' }.to_json

      stub_saml_proxy_and_analytics('SUCCESS', 'Success - REGISTER_WITH_IDP at LOA LEVEL_1')
      post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
      expect(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]).to eq(expected_cookie)
    end

    it 'should add a new status with a new entity id to the existing statuses' do
      expected_cookie = "{" +
        "\"entity_id\":\"http://idcorp.com\"," +
        "\"simple_id\":\"stub-idp-one\"," +
        "\"levels_of_assurance\":[\"LEVEL_1\",\"LEVEL_2\"]," +
        "\"SUCCESS\":\"http://success-idcorp.com\"," +
        "\"PENDING\":\"http://idcorp.com\"" +
        "}"

      session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2), 'SUCCESS' => 'http://success-idcorp.com' }.to_json

      stub_saml_proxy_and_analytics('PENDING', 'Paused - REGISTER_WITH_IDP')
      post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
      expect(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]).to eq(expected_cookie)
    end

    it 'should add a new failure status with idp entity id as a value to the journey hint cookie when the response is OTHER' do
      expected_cookie = "{\"FAILED\":\"http://idcorp.com\"}"

      session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }

      stub_saml_proxy_and_analytics('FAILED', 'Failure - REGISTER_WITH_IDP')
      post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
      expect(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]).to eq(expected_cookie)
    end
  end
end
