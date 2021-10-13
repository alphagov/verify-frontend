# frozen_string_literal: true

module ApiTestHelper
  include ConfigEndpoints
  include SamlProxyEndpoints
  include PolicyEndpoints

  ORIGINATING_IP = "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>"
  IDP_LOCATION = "/test-idp-request-endpoint"

  def saml_proxy_api_uri(path)
    URI.join(CONFIG.saml_proxy_host, path)
  end

  def config_api_uri(path)
    URI.join(CONFIG.config_api_host, path)
  end

  def policy_api_uri(path)
    URI.join(CONFIG.policy_host, path)
  end

  def api_transactions_endpoint
    config_api_uri("/config/transactions/enabled")
  end

  def api_transactions_for_single_idp_endpoint
    config_api_uri("/config/transactions/single-idp-enabled-list")
  end

  def api_translations_endpoint(simple_id, locale)
    config_api_uri("/config/transactions/#{simple_id}/translations/#{locale}")
  end

  def stub_transactions_list
    transactions = [
      {
        "simpleId" => "test-rp", "serviceHomepage" => "http://localhost:50130/test-rp",
        "loaList" => %w(LEVEL_2), "headlessStartpage" => "http://localhost:50130/success?rp-name=test-rp"
      },
      {
        "simpleId" => "test-rp-noc3", "serviceHomepage" => "http://localhost:50130/test-rp-noc3",
        "loaList" => %w(LEVEL_2), "headlessStartpage" => nil
      },
      {
        "simpleId" => "headless-rp", "serviceHomepage" => "http://localhost:50130/headless-rp",
        "loaList" => %w(LEVEL_2), "headlessStartpage" => nil
      },
      {
        "simpleId" => "test-rp-with-custom-hint", "serviceHomepage" => "http://localhost:50130/test-rp-with-custom-hint",
        "loaList" => %w(LEVEL_2), "headlessStartpage" => "http://localhost:50130/success?rp-name=test-rp-with-custom-hint"
      },
      {
        "simpleId" => "loa1-test-rp", "serviceHomepage" => "http://localhost:50130/loa1-test-rp",
        "loaList" => %w(LEVEL_1 LEVEL_2), "headlessStartpage" => "http://localhost:50130/success?rp-name=loa1-test-rp"
      },
    ]

    stub_request(:get, api_transactions_endpoint).to_return(body: transactions.to_json, status: 200)
  end

  def stub_transactions_for_single_idp_list(localhost_port = nil)
    localhost_port ||= 50130
    transactions_for_single_idp_list = [
      { "simpleId" => "test-rp", "entityId" => "http://www.test-rp.gov.uk/SAML2/MD", "redirectUrl" => "http://localhost:#{localhost_port}/test-saml", "loaList" => %w(LEVEL_2) },
      { "simpleId" => "test-rp-noc3", "entityId" => "some-other-entity-id", "redirectUrl" => "http://localhost:#{localhost_port}/test-saml", "loaList" => %w(LEVEL_2) },
      { "simpleId" => "headless-rp", "entityId" => "some-entity-id", "redirectUrl" => "http://localhost:#{localhost_port}/headless-rp", "loaList" => %w(LEVEL_2) },
    ]

    stub_request(:get, api_transactions_for_single_idp_endpoint).to_return(body: transactions_for_single_idp_list.to_json, status: 200)
  end

  def stub_translations
    en_translation_data = '{
        "name":"test GOV.UK Verify user journeys",
        "rpName":"Test RP",
        "analyticsDescription":"analytics description for test-rp",
        "otherWaysText":"<p>If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul class=\"govuk-list govuk-list--bullet\"><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        "otherWaysDescription":"test GOV.UK Verify user journeys",
        "tailoredText":"External data source: EN: This is tailored text for test-rp",
        "taxonName":"Benefits",
        "singleIdpStartPageTitle": "This is the Single IDP Start Page Title",
        "singleIdpStartPageContent": "This is the Single IDP Start Page Content <a href=\'%<start_url>s\'>Sign In</a>"
      }'
    stub_request(:get, api_translations_endpoint("test-rp", "en")).to_return(body: en_translation_data, status: 200)
    cy_translation_data = '{
        "name":"Welsh test GOV.UK Verify user journeys",
        "rpName":"Welsh Test RP",
        "analyticsDescription":"analytics description for test-rp",
        "otherWaysText":"<p>Welsh If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul class=\"govuk-list govuk-list--bullet\"><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        "otherWaysDescription":"Welsh test GOV.UK Verify user journeys",
        "tailoredText":"Welsh External data source: EN: This is tailored text for test-rp",
        "taxonName":"Welsh Benefits",
        "singleIdpStartPageTitle": "This is the Single IDP Start Page Title-Welsh",
        "singleIdpStartPageContent": "This is the Single IDP Start Page Content in Welsh <a href=\'%<start_url>s\'>Sign In</a>"
      }'
    stub_request(:get, api_translations_endpoint("test-rp", "cy")).to_return(body: cy_translation_data, status: 200)
    test_rp_noc3_translations = '{
        "name":"Test GOV.UK Verify user journeys (forceauthn & no cycle3)",
        "rpName":"Test RP",
        "analyticsDescription":"analytics description for test-rp",
        "otherWaysText":"<p>If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul class=\"govuk-list govuk-list--bullet\"><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        "otherWaysDescription":"test GOV.UK Verify user journeys",
        "tailoredText":"External data source: EN: This is tailored text for test-rp",
        "taxonName":"Benefits"
      }'
    stub_request(:get, api_translations_endpoint("test-rp-noc3", "en")).to_return(body: test_rp_noc3_translations, status: 200)
    stub_request(:get, api_translations_endpoint("test-rp-noc3", "cy")).to_return(body: "{}", status: 200)
    stub_request(:get, api_translations_endpoint("loa1-test-rp", "en")).to_return(body: test_rp_noc3_translations, status: 200)
    stub_request(:get, api_translations_endpoint("loa1-test-rp", "cy")).to_return(body: "{}", status: 200)
    stub_request(:get, api_translations_endpoint("headless-rp", "en")).to_return(body: en_translation_data, status: 200)
    stub_request(:get, api_translations_endpoint("headless-rp", "cy")).to_return(body: "{}", status: 200)
    stub_request(:get, api_translations_endpoint("test-rp-no-ab-test", "en")).to_return(body: en_translation_data, status: 200)
    stub_request(:get, api_translations_endpoint("test-rp-no-ab-test", "cy")).to_return(body: "{}", status: 200)
    stub_request(:get, api_translations_endpoint("test-rp-no-demo", "en")).to_return(body: '{
        "name":"test GOV.UK Verify user journeys",
        "rpName":"Test RP",
        "analyticsDescription":"analytics description for test-rp",
        "otherWaysText":"<p>If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul class=\"govuk-list govuk-list--bullet\"><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        "otherWaysDescription":"test GOV.UK Verify user journeys",
        "tailoredText":"External data source: EN: This is tailored text for test-rp",
        "taxonName":"Benefits",
        "customFailHeading":"This is a custom fail page.",
        "customFailOtherOptions":"Custom text to be provided by RP.",
        "customFailWhatNextContent":"This is custom what next content.",
        "customFailTryAnotherSummary":"This is custom try another summary.",
        "customFailTryAnotherText":"This is custom try another text.",
        "customFailContactDetailsIntro":"This is custom contact details."
      }', status: 200)
    stub_request(:get, api_translations_endpoint("test-rp-no-demo", "cy")).to_return(body: '{
        "name":"Test GOV.UK Verify user journeys (forceauthn & no cycle3)",
        "rpName":"EN: Test RP",
        "analyticsDescription":"analytics description for test-rp",
        "otherWaysText":"<p>If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul class=\"govuk-list govuk-list--bullet\"><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        "otherWaysDescription":"test GOV.UK Verify user journeys",
        "tailoredText":"External data source: EN: This is tailored text for test-rp",
        "taxonName":"Benefits",
        "customFailHeading":"This is a custom fail page in welsh.",
        "customFailOtherOptions":"Custom text to be provided by RP.",
        "customFailWhatNextContent":"This is custom what next content.",
        "customFailTryAnotherSummary":"This is custom try another summary.",
        "customFailTryAnotherText":"This is custom try another text.",
        "customFailContactDetailsIntro":"This is custom contact details."
      }', status: 200)
    stub_request(:get, api_translations_endpoint("foobar", "en")).to_return(body: en_translation_data, status: 200)
    stub_request(:get, api_translations_endpoint("foobar", "cy")).to_return(body: "{}", status: 200)
    stub_request(:get, api_translations_endpoint("test-rp-custom-hint", "en")).to_return(body: '{
        "name":"test GOV.UK Verify user journeys",
        "rpName":"Test RP with custom hint",
        "analyticsDescription":"analytics description for test-rp",
        "otherWaysText":"<p>If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul class=\"govuk-list govuk-list--bullet\"><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        "otherWaysDescription":"test GOV.UK Verify user journeys",
        "tailoredText":"External data source: EN: This is tailored text for test-rp",
        "taxonName":"Benefits",
        "singleIdpStartPageTitle": "This is the Single IDP Start Page Title",
        "singleIdpStartPageContent": "This is the Single IDP Start Page Content <a href=\'%<start_url>s\'>Sign In</a>",
        "idpDisconnectedAlternativeHtml": "An alternative hint warning."
      }', status: 200)
    stub_request(:get, api_translations_endpoint("test-rp-custom-hint", "cy")).to_return(body: " {}", status: 200)
  end

  def an_authn_request(location, registration)
    {
      "postEndpoint" => location,
      "samlMessage" => "a-saml-request",
      "relayState" => "a-relay-state",
      "registration" => registration,
    }
  end

  def stub_session_select_idp_request(encrypted_entity_id, request_body = {})
    stub = stub_request(:post, policy_api_uri(select_idp_endpoint(default_session_id)))
    if request_body.any?
      stub = stub.with(body: request_body)
    end
    stub.to_return(body: { "encryptedEntityId" => encrypted_entity_id }.to_json, status: 201)
  end

  def stub_session_idp_authn_request(originating_ip = ORIGINATING_IP, idp_location = IDP_LOCATION, registration: false)
    stub_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
      .with(headers: { "X_FORWARDED_FOR" => originating_ip })
      .to_return(body: an_authn_request(idp_location, registration).to_json)
  end

  def an_error_response(code)
    {
      exceptionType: code,
    }
  end

  def stub_session_creation(options = {})
    stub_saml_proxy_authn_request_endpoint
    stub_policy_sign_in_process_details(options)
    stub_transaction_details(options)
  end

  def stub_session_creation_error
    stub_request(:post, saml_proxy_api_uri(NEW_SESSION_ENDPOINT)).to_return(body: { "not_a_real_exception_response" => "something went really wrong" }.to_json, status: 500)
  end

  def stub_saml_proxy_authn_request_endpoint
    authn_request_body = {
      PARAM_SAML_REQUEST => "my-saml-request",
      PARAM_RELAY_STATE => "my-relay-state",
      PARAM_IP_SEEN_BY_FRONTEND => "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>",
    }
    stub_request(:post, saml_proxy_api_uri(NEW_SESSION_ENDPOINT)).with(body: authn_request_body).to_return(body: default_session_id.to_json, status: 200)
  end

  def stub_policy_sign_in_process_details(options = {})
    stub_request(:get, policy_api_uri(sign_in_process_details_endpoint(default_session_id))).to_return(body: sign_in_process_details_stub_response(options).to_json, status: 200)
  end

  def sign_in_process_details_stub_response(options)
    defaults = {
      "requestIssuerId" => default_transaction_entity_id,
    }
    defaults.merge(options)
  end

  def stub_transaction_details(options = {})
    stub_request(:get, config_api_uri(transaction_display_data_endpoint(default_transaction_entity_id))).to_return(body: transaction_details_stub_response(options).to_json, status: 200)
  end

  def stub_missing_transaction_details(body: { clientMessage: "NONE", exceptionType: "NONE", errorId: "NONE", Referer: "" }, status: 400)
    stub_request(:get, config_api_uri(transaction_display_data_endpoint(default_transaction_entity_id))).to_return(body: body.to_json, status: status)
  end

  def transaction_details_stub_response(options)
    defaults = {
      "simpleId" => "test-rp",
      "serviceHomepage" => "http://www.test-rp.gov.uk/",
      "loaList" => %w(LEVEL_1 LEVEL_2),
      "headlessStartpage" => "http://www.test-rp.gov.uk/success",
    }
    defaults.merge(options)
  end

  def stub_matching_outcome(outcome = MatchingOutcomeResponse::WAIT)
    stub_request(:get, policy_api_uri(matching_outcome_endpoint(default_session_id))).to_return(body: { "responseProcessingStatus" => outcome }.to_json)
  end

  def x_forwarded_for
    { "X-Forwarded-For" => "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  end

  def stub_response_for_rp
    response_body = {
      "postEndpoint" => "/test-rp",
      "samlMessage" => "a saml message",
      "relayState" => "a relay state",
    }
    stub_request(:get, saml_proxy_api_uri(response_for_rp_endpoint(default_session_id))).with(headers: x_forwarded_for).to_return(body: response_body.to_json)
  end

  def stub_error_response_for_rp
    response_body = {
      "postEndpoint" => "/test-rp",
      "samlMessage" => "a saml message",
      "relayState" => "a relay state",
    }
    stub_request(:get, saml_proxy_api_uri(error_response_for_rp_endpoint(default_session_id))).with(headers: x_forwarded_for).to_return(body: response_body.to_json)
  end

  def stub_cycle_three_attribute_request(name)
    cycle_three_attribute_name = { attributeName: name }
    stub_request(:get, policy_api_uri(cycle_three_endpoint(default_session_id))).to_return(body: cycle_three_attribute_name.to_json, status: 200)
  end

  def stub_cycle_three_value_submit(value)
    cycle_three_attribute_value = { PARAM_CYCLE_3_INPUT => value, PARAM_PRINCIPAL_IP => OriginatingIpStore::UNDETERMINED_IP }
    stub_request(:post, policy_api_uri(cycle_three_submit_endpoint(default_session_id))).with(body: cycle_three_attribute_value.to_json).to_return(status: 200)
  end

  def stub_cycle_three_cancel
    stub_request(:post, policy_api_uri(cycle_three_cancel_endpoint(default_session_id))).to_return(status: 200)
  end

  def stub_api_authn_response(relay_state, response = { "result" => "SUCCESS", "isRegistration" => false })
    authn_response_body = {
      PARAM_SAML_REQUEST => "my-saml-response",
      PARAM_RELAY_STATE => relay_state,
      PARAM_IP_SEEN_BY_FRONTEND => "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>",
      PARAM_PERSISTENT_SESSION_ID => instance_of(String),
      PARAM_JOURNEY_TYPE => nil,
    }

    stub_request(:post, saml_proxy_api_uri(IDP_AUTHN_RESPONSE_ENDPOINT))
      .with(body: authn_response_body)
      .to_return(body: response.to_json, status: 200)
  end

  def stub_api_returns_error(code)
    stub_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
      .to_return(body: an_error_response(code).to_json, status: 500)
  end

  def stub_api_idp_list_for_registration(idps = default_idps, loa: "LEVEL_2")
    stub_request(:get, config_api_uri(idp_list_for_registration_endpoint(default_transaction_entity_id, loa))).to_return(body: idps.to_json)
  end

  def stub_api_idp_list_for_sign_in(idps = default_idps)
    stub_request(:get, config_api_uri(idp_list_for_sign_in_endpoint(default_transaction_entity_id))).to_return(body: idps.to_json)
  end

  def stub_api_idp_list_for_sign_in_without_session(idps = default_idps, transaction_entity_id = default_transaction_entity_id)
    stub_request(:get, config_api_uri(idp_list_for_sign_in_endpoint(transaction_entity_id))).to_return(body: idps.to_json)
  end

  def stub_api_idp_list_for_single_idp_journey(transaction_id = default_transaction_entity_id, idps = default_idps)
    stub_request(:get, config_api_uri(idp_list_for_single_idp_endpoint(transaction_id))).to_return(body: idps.to_json)
  end

  def stub_api_select_idp
    stub_request(:post, policy_api_uri(select_idp_endpoint(default_session_id))).to_return(status: 201)
  end

  def stub_restart_journey
    stub_request(:post, policy_api_uri(restart_journey_endpoint(default_session_id))).to_return(status: 200)
  end

  def stub_api_no_docs_idps
    idps = [
      { "simpleId" => "stub-idp-one", "entityId" => "http://idcorp.com", "levelsOfAssurance" => %w(LEVEL_2) },
      { "simpleId" => "stub-idp-no-docs", "entityId" => "http://idcorp.nodoc.com", "levelsOfAssurance" => %w(LEVEL_2) },
      { "simpleId" => "stub-idp-two", "entityId" => "other-entity-id", "levelsOfAssurance" => %w(LEVEL_2) },
      { "simpleId" => "stub-idp-three", "entityId" => "a-different-entity-id", "levelsOfAssurance" => %w(LEVEL_2) },
    ]
    stub_api_idp_list_for_registration(idps)
  end

  def stub_hub_config_healthcheck(status: 200)
    stub_request(:get, config_api_uri("service-status")).to_return(status: status)
  end

private

  def default_session_id
    "my-session-id-cookie"
  end

  def default_transaction_id
    "test-rp"
  end

  def default_transaction_entity_id
    "http://www.test-rp.gov.uk/SAML2/MD"
  end

  def default_idps
    [
      { "simpleId" => "stub-idp-one", "entityId" => "http://idcorp.com", "levelsOfAssurance" => %w(LEVEL_2) },
      { "simpleId" => "stub-idp-two", "entityId" => "http://idcorp-two.com", "levelsOfAssurance" => %w(LEVEL_2) },
      { "simpleId" => "stub-idp-three", "entityId" => "http://idcorp-three.com", "levelsOfAssurance" => %w(LEVEL_2) },
      { "simpleId" => "stub-idp-demo", "entityId" => "http://idcorp-demo.com", "levelsOfAssurance" => %w(LEVEL_2) },
      { "simpleId" => "stub-idp-loa1", "entityId" => "http://idcorp-loa1.com", "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2) },
      { "simpleId" => "stub-idp-disconnected", "entityId" => "http://idcorp-disconnected.com", "levelsOfAssurance" => %w(LEVEL_1 LEVEL_2), "authenticationEnabled" => false },
    ]
  end
end

RSpec.configure do |c|
  c.include ApiTestHelper
end
