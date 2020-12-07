require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "support/authn_request_redirect_examples"

describe AuthnRequestController do
  let(:valid_rp) { "test-rp-no-demo" }
  let(:valid_idp) { "http://idcorp.com" }
  let(:ga_id) { "123456" }

  before :each do
    stub_session_creation
  end

  context "where GA cross domain tracking parameter is NOT included in request" do
    include_examples "idp_authn_request_redirects"
  end

  context "where GA cross domain tracking parameter is included in request" do
    include_examples "idp_authn_request_redirects", "_ga" => "123456"
  end

  it "will redirect the user to default start page and maintain _ga parameter if cookie is missing" do
    post :rp_request, params: { "_ga" => :ga_id, "SAMLRequest" => "my-saml-request", "RelayState" => "my-relay-state" }
    expect(response).to redirect_to start_path(_ga: :ga_id)
  end

  it "will show error page when SAMLRequest param is missing" do
    post :rp_request, params: { "RelayState" => "my-relay-state" }
    expect(response).to have_http_status :bad_request
  end

  it "will show error page when SAMLRequest param is empty string" do
    post :rp_request, params: { "SAMLRequest" => "", "RelayState" => "my-relay-state" }
    expect(response).to have_http_status :bad_request
  end

  it "will show error page when SAMLRequest param is nil" do
    post :rp_request, params: { "SAMLRequest" => nil, "RelayState" => "my-relay-state" }
    expect(response).to have_http_status :bad_request
  end

  context "authn request without sign in hint" do
    it "will route to blue start path when transaction enabled for eidas and past eu exit date" do
      stub_session_creation("transactionSupportsEidas" => true)
      allow(CONFIG).to receive(:eidas_disabled_after).and_return(1.day.ago)
      post :rp_request, params: { "_ga" => :ga_id, "SAMLRequest" => "my-saml-request", "RelayState" => "my-relay-state" }
      expect(response).to redirect_to start_path(_ga: :ga_id)
    end

    it "will route to blue start path when transaction not enabled for eidas and past eu exit date" do
      stub_session_creation("transactionSupportsEidas" => false)
      allow(CONFIG).to receive(:eidas_disabled_after).and_return(1.day.ago)
      post :rp_request, params: { "_ga" => :ga_id, "SAMLRequest" => "my-saml-request", "RelayState" => "my-relay-state" }
      expect(response).to redirect_to start_path(_ga: :ga_id)
    end

    it "will route to prove identity page when transaction enabled for eidas and before eu exit date" do
      stub_session_creation("transactionSupportsEidas" => true)
      allow(CONFIG).to receive(:eidas_disabled_after).and_return(1.day.from_now)
      post :rp_request, params: { "_ga" => :ga_id, "SAMLRequest" => "my-saml-request", "RelayState" => "my-relay-state" }
      expect(response).to redirect_to prove_identity_path(_ga: :ga_id)
    end

    it "will route to prove identity page when transaction enabled for eidas and no eu exit config set" do
      stub_session_creation("transactionSupportsEidas" => true)
      allow(CONFIG).to receive(:eidas_disabled_after).and_return(nil)
      post :rp_request, params: { "_ga" => :ga_id, "SAMLRequest" => "my-saml-request", "RelayState" => "my-relay-state" }
      expect(response).to redirect_to prove_identity_path(_ga: :ga_id)
    end
  end

  context "authn request with journey_hint set to eidas_sign_in" do
    it "will route to blue start path when transaction enabled for eidas and past eu exit date" do
      stub_session_creation("transactionSupportsEidas" => true)
      allow(CONFIG).to receive(:eidas_disabled_after).and_return(1.day.ago)
      post :rp_request, params: { "_ga" => :ga_id, "SAMLRequest" => "my-saml-request", "RelayState" => "my-relay-state", "journey_hint" => "eidas_sign_in" }
      expect(response).to redirect_to start_path(_ga: :ga_id)
    end

    it "will route to blue start path when transaction not enabled for eidas and past eu exit date" do
      stub_session_creation("transactionSupportsEidas" => false)
      allow(CONFIG).to receive(:eidas_disabled_after).and_return(1.day.ago)
      post :rp_request, params: { "_ga" => :ga_id, "SAMLRequest" => "my-saml-request", "RelayState" => "my-relay-state", "journey_hint" => "eidas_sign_in" }
      expect(response).to redirect_to start_path(_ga: :ga_id)
    end

    it "will route to prove identity page when transaction enabled for eidas and before eu exit date" do
      stub_session_creation("transactionSupportsEidas" => true)
      allow(CONFIG).to receive(:eidas_disabled_after).and_return(1.day.from_now)
      post :rp_request, params: { "_ga" => :ga_id, "SAMLRequest" => "my-saml-request", "RelayState" => "my-relay-state", "journey_hint" => "eidas_sign_in" }
      expect(response).to redirect_to choose_a_country_path(_ga: :ga_id)
    end
  end
end
