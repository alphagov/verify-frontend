shared_examples 'idp_authn_response' do |journey_hint, idp_result, piwik_action, redirect_path|
  let(:saml_proxy_api) { double(:saml_proxy_api) }
  let(:selected_entity) {
    {
      'entity_id' => 'https://acme.de/ServiceMetadata',
      'simple_id' => 'DE',
      'levels_of_assurance' => %w[LEVEL_1 LEVEL_2]
    }
  }

  before(:each) do
    stub_const('SAML_PROXY_API', saml_proxy_api)
    set_session_and_cookies_with_loa('LEVEL_1')
    cookies[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = 'pretend cookie'
    set_selected_idp(selected_entity)
    session[:journey_type] = journey_hint
  end

  it "should redirect to #{redirect_path} on #{idp_result}" do
    allow(saml_proxy_api).to receive(:idp_authn_response).and_return(IdpAuthnResponse.new('result' => idp_result, 'isRegistration' => (journey_hint == 'registration'), 'loaAchieved' => 'LEVEL_1'))
    allow(subject).to receive(:report_to_analytics).with(piwik_action)
    allow(subject).to receive(:report_user_outcome_to_piwik).with(idp_result)
    post :idp_response, params: { 'RelayState' => 'my-session-id-cookie', 'SAMLResponse' => 'a-saml-response', locale: 'en' }
    expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be_nil
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
