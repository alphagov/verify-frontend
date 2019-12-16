require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'support/authn_request_redirect_examples'

describe AuthnRequestController do
  let(:valid_rp) { 'test-rp-no-demo' }
  let(:valid_idp) { 'http://idcorp.com' }
  let(:ga_id) { '123456' }

  before :each do
    stub_session_creation
  end

  context 'where GA cross domain tracking parameter is NOT included in request' do
    include_examples 'idp_authn_request_redirects'
  end

  context 'where GA cross domain tracking parameter is included in request' do
    include_examples 'idp_authn_request_redirects', '_ga' => '123456'
  end

  it 'will redirect the user to default start page and maintain _ga parameter if cookie is missing' do
    post :rp_request, params: { '_ga' => :ga_id, 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
    expect(response).to redirect_to start_path(_ga: :ga_id)
  end

  it 'will show error page when SAMLRequest param is missing' do
    post :rp_request, params: { 'RelayState' => 'my-relay-state' }
    expect(response).to have_http_status :bad_request
  end

  it 'will show error page when SAMLRequest param is empty string' do
    post :rp_request, params: { 'SAMLRequest' => '', 'RelayState' => 'my-relay-state' }
    expect(response).to have_http_status :bad_request
  end

  it 'will show error page when SAMLRequest param is nil' do
    post :rp_request, params: { 'SAMLRequest' => nil, 'RelayState' => 'my-relay-state' }
    expect(response).to have_http_status :bad_request
  end

  it 'will set hint in flash and redirect to redirect_to_idp_sign_in_with_last_successful_idp_path if idp hint' do
    post :rp_request, params: { '_ga' => :ga_id, 'journey_hint' => 'idp_simple_id', 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }
    expect(response).to redirect_to redirect_to_idp_sign_in_with_last_successful_idp_path(_ga: :ga_id)
    expect(flash[:journey_hint]).to eq('idp_simple_id')
  end
end
