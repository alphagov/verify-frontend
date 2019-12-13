require 'feature_helper'
require 'api_test_helper'

describe 'pages redirect with journey hint parameter', type: :request do
  context 'when user has NOT been redirected via /initiate-journey so does not have journey hint in session' do
    it 'will redirect the user to verify start path when journey hint parameter is set to uk_idp_start' do
      stub_session_creation
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'uk_idp_start' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to registration path when journey hint parameter is set to registration' do
      stub_session_creation
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'registration' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to sign-in path when journey hint parameter is set to uk_idp_sign_in' do
      stub_session_creation
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'uk_idp_sign_in' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to non-repudiation path when journey hint parameter is set to submission_confirmation' do
      stub_session_creation
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'submission_confirmation' }
      expect(response).to redirect_to confirm_your_identity_path
    end

    it 'will redirect the user to start path path when journey hint parameter is an unknown value' do
      stub_session_creation
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'foobar' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to start path when journey hint parameter is not present' do
      stub_session_creation
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to IDP sign in when journey hint parameter is set to idp_simple_id' do
      stub_session_creation
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'idp_something' }
      expect(response).to redirect_to redirect_to_idp_sign_in_with_last_successful_idp_path
    end
  end

  context 'when transaction is Eidas enabled' do
    it 'will redirect the user to eidas enabled start path when journey hint parameter is not present and eidas is enabled' do
      stub_session_creation('transactionSupportsEidas' => true)
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to prove_identity_path
    end

    it 'will redirect the user to start path path when journey hint parameter is an unknown value and eidas is enabled' do
      stub_session_creation('transactionSupportsEidas' => true)
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'foobar' }
      expect(response).to redirect_to prove_identity_path
    end

    it 'will redirect the user to eidas country picker path when journey hint parameter is set to eidas_sign_in and eidas is enabled' do
      stub_session_creation('transactionSupportsEidas' => true)
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'eidas_sign_in' }
      expect(response).to redirect_to choose_a_country_path
    end

    it 'will redirect the user to eidas country picker path when journey hint parameter is set to eidas_sign_in and eidas is disabled' do
      stub_session_creation
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'eidas_sign_in' }
      expect(response).to redirect_to start_path
    end
  end

  context 'when user has been redirected via /initiate-journey so do have journey hint in session' do
    it 'will redirect the user to verify start path when journey hint session parameter is set to uk_idp_start' do
      stub_session_creation
      initialise_journey_hint('uk_idp_start')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to registration path when journey hint session parameter is set to registration' do
      stub_session_creation
      initialise_journey_hint('registration')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to sign-in path when journey hint session parameter is set to uk_idp_sign_in' do
      stub_session_creation
      initialise_journey_hint('uk_idp_sign_in')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to non-repudiation path when journey hint session parameter is set to submission_confirmation' do
      stub_session_creation
      initialise_journey_hint('submission_confirmation')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to confirm_your_identity_path
    end

    it 'will redirect the user to start path path when journey hint session parameter is an unknown value' do
      stub_session_creation
      initialise_journey_hint('blah')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end
  end

  context 'when user has been redirected via /initiate-journey so do have journey hint in session AND a journey_hint form parameter is present' do
    it 'will redirect the user to verify start path when journey hint parameter is set to uk_idp_start' do
      stub_session_creation
      initialise_journey_hint('registration')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'uk_idp_start' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to registration path when journey hint parameter is set to registration' do
      stub_session_creation
      initialise_journey_hint('uk_idp_start')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'registration' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to sign-in path when journey hint parameter is set to uk_idp_sign_in' do
      stub_session_creation
      initialise_journey_hint('registration')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'uk_idp_sign_in' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to non-repudiation path when journey hint parameter is set to submission_confirmation' do
      stub_session_creation
      initialise_journey_hint('registration')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'submission_confirmation' }
      expect(response).to redirect_to confirm_your_identity_path
    end
  end

  context 'when user has been redirected via /initiate-journey so do have journey hint in session with invalid RP stored' do
    it 'will redirect the user to verify start path when journey hint parameter is set to uk_idp_start' do
      stub_session_creation
      initialise_journey_hint('registration', 'bad-rp')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to registration path when journey hint parameter is set to registration' do
      stub_session_creation
      initialise_journey_hint('uk_idp_start', 'bad-rp')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to sign-in path when journey hint parameter is set to uk_idp_sign_in' do
      stub_session_creation
      initialise_journey_hint('registration', 'bad-rp')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end

    it 'will redirect the user to non-repudiation path when journey hint parameter is set to submission_confirmation' do
      stub_session_creation
      initialise_journey_hint('registration', 'bad-rp')
      post '/SAML2/SSO', params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
      expect(response).to redirect_to start_path
    end
  end
end
