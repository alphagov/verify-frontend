require "rails_helper"
require "controller_helper"
require "spec_helper"
require "api_test_helper"

describe PublishHubConfigController do
  let(:entity_id) { "http://www.test-rp.gov.uk/SAML2/MD" }
  let(:host) { "http://api.com:50240" }
  let(:authentication_header) { "test-header" }

  context "#service-status" do
    it "should return 200 response" do
      request.headers[:'X-Self-Service-Authentication'] = authentication_header
      stub_hub_config_healthcheck
      get :service_status, params: { locale: "en" }
      expect(response).to have_http_status(:ok)
    end

    it "should return same response code as the upstream healthcheck" do
      request.headers[:'X-Self-Service-Authentication'] = authentication_header
      stub_hub_config_healthcheck(status: 502)
      get :service_status, params: { locale: "en" }
      expect(response).to have_http_status(502)
    end

    it "should return unauthorized if header missing" do
      get :service_status, params: { locale: "en" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "should return unauthorized if authentication header missing" do
      request.headers[:'X-Self-Service-Authentication'] = "wrong"
      get :service_status, params: { locale: "en" }
      expect(response).to have_http_status(401)
    end
  end

  context "#certificates" do
    it "should return signing certs in the response" do
      request.headers[:'X-Self-Service-Authentication'] = authentication_header
      signing_certificates = '
        [{
          "issuerId":"http://www.test-rp.gov.uk/SAML2/MD",
          "certificate":"certificate-value-primary",
          "keyUse":"Signing",
          "federationEntityType":"RP"
        },
        {
          "issuerId":"http://www.test-rp.gov.uk/SAML2/MD",
          "certificate":"certificate-value-secondary",
          "keyUse":"Signing",
          "federationEntityType":"RP"
        }]
      '
      path = CGI.escape(entity_id) + "/certs/signing"

      stub_request(:get, "#{host}/config/certificates/#{CGI.escape(path)}").and_return(status: 200, body: signing_certificates)
      get :certificates, params: { locale: "en", path: path }

      expect(response).to have_http_status(200)
      expect(response.body).to eql(signing_certificates)
    end

    it "should return an encryption cert in the response" do
      request.headers[:'X-Self-Service-Authentication'] = authentication_header
      encryption_certificate = '
        {
          "issuerId":"http://www.test-rp.gov.uk/SAML2/MD",
          "certificate":"encryption-certificate-valuey",
          "keyUse":"Encryption",
          "federationEntityType":"RP"
        }
      '
      path = CGI.escape(entity_id) + "/certs/encryption"

      stub_request(:get, "#{host}/config/certificates/#{CGI.escape(path)}").and_return(status: 200, body: encryption_certificate)
      get :certificates, params: { locale: "en", path: path }

      expect(response).to have_http_status(200)
      expect(response.body).to eql(encryption_certificate)
    end

    it "should return the same error and same http status as the config service" do
      request.headers[:'X-Self-Service-Authentication'] = authentication_header
      wrong_entity_id = "wrong-entity-id"
      error_code = 404
      error_message = '
        {
          "code":' + error_code.to_s + ',
          "message":"\'' + wrong_entity_id + '\' - No data is configured for this entity."
        }
      '
      path = CGI.escape(wrong_entity_id) + "/certs/encryption"

      stub_request(:get, "#{host}/config/certificates/#{CGI.escape(path)}").and_return(status: error_code, body: error_message)
      get :certificates, params: { locale: "en", path: path }

      expect(response).to have_http_status(error_code)
      expect(response.body).to eql(error_message)
    end

    it "should return unauthorized if header missing" do
      get :certificates, params: { locale: "en", path: "path" }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
