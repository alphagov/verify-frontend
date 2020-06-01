require "spec_helper"
require "rails_helper"
require "models/saml_proxy_api"
require "cookie_names"

describe SamlProxyApi do
  let(:x_forwarded_for) { "X-Forwarded-For".freeze }
  let(:api_client) { double(:api_client) }
  let(:originating_ip_store) { double(:originating_ip_store) }
  let(:session_id) { "my-session-id" }
  let(:journey_type) { "sign-in" }
  let(:persistent_session_id) { "my-persistent_session_id" }
  let(:cookies) {
    {
        CookieNames::SESSION_ID_COOKIE_NAME => session_id,
    }
  }
  let(:session) {
    {
        start_time: "my-session-start-time",
    }
  }
  let(:saml_proxy_api) { SamlProxyApi.new(api_client, originating_ip_store) }
  let(:ip_address) { "127.0.0.1" }

  include SamlProxyEndpoints

  describe "#response_for_rp" do
    it "should return an rp response" do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(response_for_rp_endpoint(session_id), headers: { x_forwarded_for => ip_address })
        .and_return("postEndpoint" => "http://www.example.com",
                    "samlMessage" => "a saml message",
                    "relayState" => "a relay state")

      actual_response = saml_proxy_api.response_for_rp(session_id)

      expected_attributes = {
          "location" => "http://www.example.com",
          "saml_message" => "a saml message",
          "relay_state" => "a relay state",
      }
      expect(actual_response).to have_attributes(expected_attributes)
    end

    it "should raise an error when the API responds with an unknown value" do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(response_for_rp_endpoint(session_id), headers: { x_forwarded_for => ip_address })
        .and_return("outcome" => "BANANA")

      expect {
        saml_proxy_api.response_for_rp(session_id)
      }.to raise_error(Api::Response::ModelError, "Location can't be blank, Saml message can't be blank")
    end
  end

  describe "#error_response_for_rp" do
    it "should return an rp response" do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(error_response_for_rp_endpoint(session_id), headers: { x_forwarded_for => ip_address })
        .and_return("postEndpoint" => "http://www.example.com",
                    "samlMessage" => "a saml message",
                    "relayState" => "a relay state")

      actual_response = saml_proxy_api.error_response_for_rp(session_id)

      expected_attributes = {
          "location" => "http://www.example.com",
          "saml_message" => "a saml message",
          "relay_state" => "a relay state",
      }
      expect(actual_response).to have_attributes(expected_attributes)
    end

    it "should raise an error when the API responds with an unknown value" do
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:get)
        .with(error_response_for_rp_endpoint(session_id), headers: { x_forwarded_for => ip_address })
        .and_return("outcome" => "BANANA")

      expect {
        saml_proxy_api.error_response_for_rp(session_id)
      }.to raise_error(Api::Response::ModelError, "Location can't be blank, Saml message can't be blank")
    end
  end

  describe "#idp_authn_response" do
    it "should return a confirmation result" do
      ip_address = "1.2.3.4"
      expected_request = { "samlRequest" => "saml-response", "relayState" => "my-session-id",
        SamlProxyApi::PARAM_IP_SEEN_BY_FRONTEND => ip_address, SamlProxyApi::PARAM_PERSISTENT_SESSION_ID => "my-persistent_session_id",
        "journeyType" => "sign-in" }
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:post)
        .with(SamlProxyApi::IDP_AUTHN_RESPONSE_ENDPOINT, expected_request)
        .and_return(
          "result" => "some-location",
          "isRegistration" => false,
          "loaAchieved" => "LEVEL_2",
        )

      response = saml_proxy_api.idp_authn_response(session_id, "saml-response", persistent_session_id, journey_type)

      attributes = {
          idp_result: "some-location",
          is_registration: false,
          loa_achieved: "LEVEL_2",
      }
      expect(response).to have_attributes(attributes)
    end

    it "should raise an error when fields are missing from the api response" do
      ip_address = "1.2.3.4"
      expected_request = { "samlRequest" => "saml-response", "relayState" => "my-session-id",
        SamlProxyApi::PARAM_IP_SEEN_BY_FRONTEND => ip_address, SamlProxyApi::PARAM_PERSISTENT_SESSION_ID => "my-persistent_session_id",
        "journeyType" => "sign-in" }
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:post)
        .with(SamlProxyApi::IDP_AUTHN_RESPONSE_ENDPOINT, expected_request)
        .and_return({})

      expect {
        saml_proxy_api.idp_authn_response(session_id, "saml-response", persistent_session_id, journey_type)
      }.to raise_error Api::Response::ModelError, "Idp result can't be blank, Is registration is not included in the list"
    end

    it "should raise an error when loa_achieved is not an accepted value" do
      ip_address = "1.2.3.4"
      expected_request = { "samlRequest" => "saml-response", "relayState" => "my-session-id",
         SamlProxyApi::PARAM_IP_SEEN_BY_FRONTEND => ip_address, SamlProxyApi::PARAM_PERSISTENT_SESSION_ID => "my-persistent_session_id",
         "journeyType" => "sign-in" }
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect(api_client).to receive(:post)
        .with(SamlProxyApi::IDP_AUTHN_RESPONSE_ENDPOINT, expected_request)
        .and_return(
          "result" => "some-location",
          "isRegistration" => false,
          "loaAchieved" => "something",
        )

      expect {
        saml_proxy_api.idp_authn_response(session_id, "saml-response", persistent_session_id, journey_type)
      }.to raise_error Api::Response::ModelError, "Loa achieved is not included in the list"
    end
  end

  describe("#authn_request") do
    it "should get an authn request" do
      authn_request = {
          "postEndpoint" => "some-location",
          "samlMessage" => "a-saml-request",
          "relayState" => "relay-state",
          "registration" => false,
      }
      ip_address = "1.1.1.1"
      expect(api_client).to receive(:get)
                                .with(authn_request_endpoint(session_id), headers: { x_forwarded_for => ip_address })
                                .and_return(authn_request)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      result = saml_proxy_api.authn_request(session_id)
      attributes = {
          "location" => "some-location",
          "saml_request" => "a-saml-request",
          "relay_state" => "relay-state",
          "registration" => false,
      }
      expect(result).to have_attributes(attributes)
    end

    it "should fail to get an IDP authn request when fields are missing from response" do
      authn_request = {
          "postEndpoint" => "some-location",
          "relayState" => "relay-state",
          "registration" => false,
      }
      ip_address = "1.1.1.1"
      expect(api_client).to receive(:get)
                                .with(authn_request_endpoint(session_id), headers: { x_forwarded_for => ip_address })
                                .and_return(authn_request)
      expect(originating_ip_store).to receive(:get).and_return(ip_address)
      expect {
        saml_proxy_api.authn_request(session_id)
      }.to raise_error Api::Response::ModelError, "Saml request can't be blank"
    end
  end
end
