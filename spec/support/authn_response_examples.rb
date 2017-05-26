shared_examples 'idp_authn_response' do |journey_hint, idp_result, piwik_action, redirect_path|
  let(:session_proxy) { double(:session_proxy) }

  before(:each) do
    # stub_request(:get, CONFIG.api_host + '/api/transactions')
    stub_const('SESSION_PROXY', session_proxy)
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  it "should redirect to #{redirect_path} on #{idp_result}" do
    allow(session_proxy).to receive(:idp_authn_response).and_return(IdpAuthnResponse.new('idpResult' => idp_result, 'isRegistration' => (journey_hint == 'registration'), 'loaAchieved' => 'LEVEL_1'))
    allow(subject).to receive(:report_to_analytics).with(piwik_action)
    post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
    expect(subject).to redirect_to(send(redirect_path))
  end
end
