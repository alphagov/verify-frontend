shared_examples 'idp_authn_response' do |journey_hint, idp_result, piwik_action, redirect_path|
  let(:saml_proxy_api) { double(:saml_proxy_api) }

  before(:each) do
    stub_const('SAML_PROXY_API', saml_proxy_api)
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  it "should redirect to #{redirect_path} on #{idp_result}" do
    allow(saml_proxy_api).to receive(:idp_authn_response).and_return(IdpAuthnResponse.new('idpResult' => idp_result, 'isRegistration' => (journey_hint == 'registration'), 'loaAchieved' => 'LEVEL_1'))
    allow(subject).to receive(:report_to_analytics).with(piwik_action)
    post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
    expect(subject).to redirect_to(send(redirect_path))
  end
end

shared_examples 'country_authn_response' do |journey_hint, country_result, redirect_path|
  let(:saml_proxy_api) { double(:saml_proxy_api) }

  before(:each) do
    stub_const('SAML_PROXY_API', saml_proxy_api)
    set_session_and_cookies_with_loa('LEVEL_1')
  end

  it "should redirect to #{redirect_path} on #{country_result}" do
    allow(saml_proxy_api).to receive(:forward_country_authn_response).and_return(CountryAuthnResponse.new('result' => country_result, 'isRegistration' => (journey_hint == 'registration'), 'loaAchieved' => 'LEVEL_1'))
    post :country_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
    expect(subject).to redirect_to(send(redirect_path))
  end
end
