shared_examples 'tracking cookie' do
  let(:saml_proxy_api) { double(:saml_proxy_api) }
  let(:status) { 'SUCCESS' }

  before(:each) do
    stub_const('SAML_PROXY_API', saml_proxy_api)
    set_session_and_cookies_with_loa('LEVEL_1')
    stub_piwik_request_with_rp_and_loa({}, 'LEVEL_1')
  end

  subject(:cookie_after_request) do
    post post_endpoint, params: { RelayState: 'my-session-id-cookie', SAMLResponse: 'a-saml-response', locale: 'en' }
    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]
  end

  context 'with no selected idp' do
    let(:selected_entity) { nil }
    it { should be_nil }
  end

  context 'receiving SUCCESS without previous cookie' do
    let(:cookie_with_just_success_status) {
      { SUCCESS: 'http://idcorp.com',
        STATE:  {
                  IDP: 'http://idcorp.com',
                  RP: 'http://www.test-rp.gov.uk/SAML2/MD',
                  STATUS: 'SUCCESS'
                } }.to_json
    }
    it { should eq cookie_with_just_success_status }
  end

  context 'receiving SUCCESS and has cookie with existing entity id' do
    let(:cookie_with_success_status_and_old_entity) {
      {
        SUCCESS: 'http://idcorp.com',
        STATE:  {
                  IDP: 'http://idcorp.com',
                  RP: 'http://www.test-rp.gov.uk/SAML2/MD',
                  STATUS: 'SUCCESS'
        }
      }.to_json
    }
    let!(:existing_cookie) {
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        'entity_id' => 'http://idcorp.com'
      }.to_json
    }
    it { should eq cookie_with_success_status_and_old_entity }
  end

  context 'receiving SUCCESS and has cookie with existing status' do
    let(:cookie_with_new_success_status) {
      {
        SUCCESS: 'http://idcorp.com',
        STATE:  {
                    IDP: 'http://idcorp.com',
                    RP: 'http://www.test-rp.gov.uk/SAML2/MD',
                    STATUS: 'SUCCESS'
                }
      }.to_json
    }
    let!(:existing_cookie) {
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        'entity_id' => 'http://old-idcorp.com',
        'SUCCESS' => 'http://old-idcorp.com',
        'STATE' => {
                      'IDP' => 'http://old-idcorp.com',
                      'RP' => 'http://www.test-rp.gov.uk/SAML2/MD',
                      'STATUS' => 'SUCCESS'
                   }
      }.to_json
    }
    it { should eq cookie_with_new_success_status }
  end

  context 'receiving new status and has cookie with existing old statuses' do
    let(:status) { 'FAILED_UPLIFT' }
    let(:cookie_with_multiple_status) {
      {
        ATTEMPT: 'http://attempt-idcorp.com',
        SUCCESS: 'http://success-idcorp.com',
        STATE: {
                  IDP: 'http://idcorp.com',
                  RP: 'http://www.test-rp.gov.uk/SAML2/MD',
                  STATUS: 'FAILED_UPLIFT'
               }
      }.to_json
    }
    let!(:existing_cookie) {
      cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
        'ATTEMPT' => 'http://attempt-idcorp.com',
        'SUCCESS' => 'http://success-idcorp.com',
        'FAILED_UPLIFT' => 'http://idcorp.com',
        'STATE' =>  {
                      'IDP' => 'http://idcorp.com',
                      'RP' => 'http://www.test-rp.gov.uk/SAML2/MD',
                      'STATUS' => 'FAILED'
                    }
      }.to_json
    }
    it { should eq cookie_with_multiple_status }
  end
end
