module ApiTestHelper
  include SessionEndpoints
  include ConfigEndpoints
  include SamlProxyEndpoints
  include PolicyEndpoints

  def ida_frontend_api_uri(path)
    URI.join(CONFIG.ida_frontend_host, path)
  end

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
    config_api_uri('/config/transactions/enabled')
  end

  def api_countries_endpoint(session_id)
    ida_frontend_api_uri('/api/countries/' + session_id)
  end

  def stub_transactions_list
    transactions = [
        { 'simpleId' => 'test-rp',      'entityId' => 'some-entity-id', 'serviceHomepage' => 'http://localhost:50130/test-rp', 'loaList' => ['LEVEL_2'] },
        { 'simpleId' => 'test-rp-noc3', 'entityId' => 'some-entity-id', 'serviceHomepage' => 'http://localhost:50130/test-rp-noc3', 'loaList' => ['LEVEL_2'] },
        { 'simpleId' => 'headless-rp',  'entityId' => 'some-entity-id', 'serviceHomepage' => 'http://localhost:50130/headless-rp', 'loaList' => ['LEVEL_2'] }
    ]

    stub_request(:get, api_transactions_endpoint).to_return(body: transactions.to_json, status: 200)
  end

  def stub_countries_list
    countries = [
        { 'entityId' => 'http://netherlandsEnitity.nl', 'simpleId' => 'NL', 'enabled' => true },
        { 'entityId' => 'http://spainEnitity.es',       'simpleId' => 'ES', 'enabled' => true },
        { 'entityId' => 'http://swedenEnitity.se',      'simpleId' => 'SE', 'enabled' => false },
    ]

    stub_request(:get, api_countries_endpoint(default_session_id)).to_return(body: countries.to_json, status: 200)
  end

  def stub_session_country_authn_request(originating_ip, country_location, registration)
    stub_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
        .with(headers: { 'X_FORWARDED_FOR' => originating_ip })
        .to_return(body: an_authn_request(country_location, registration).to_json)
  end

  def an_authn_request(location, registration)
    {
        'postEndpoint' => location,
        'samlMessage' => 'a-saml-request',
        'relayState' => 'a-relay-state',
        'registration' => registration
    }
  end

  def stub_session_select_idp_request(encrypted_entity_id, request_body = {})
    stub = stub_request(:post, policy_api_uri(select_idp_endpoint(default_session_id)))
    if request_body.any?
      stub = stub.with(body: request_body)
    end
    stub.to_return(body: { 'encryptedEntityId' => encrypted_entity_id }.to_json, status: 201)
  end

  def stub_session_idp_authn_request(originating_ip, idp_location, registration)
    stub_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
        .with(headers: { 'X_FORWARDED_FOR' => originating_ip })
        .to_return(body: an_authn_request(idp_location, registration).to_json)
  end

  def an_error_response(code)
    {
        exceptionType: code
    }
  end

  def stub_api_saml_endpoint(options = {})
    authn_request_body = {
        PARAM_SAML_REQUEST => 'my-saml-request',
        PARAM_RELAY_STATE => 'my-relay-state',
        PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
    }
    stub_request(:post, ida_frontend_api_uri('/api/session')).with(body: authn_request_body).to_return(body: stub_api_session(options).to_json, status: 201)
  end

  def stub_api_session(options = {})
    defaults = {
        'transactionSimpleId' => 'test-rp',
        'transactionEntityId' => 'http://www.test-rp.gov.uk/SAML2/MD',
        'sessionStartTime' => '32503680000000',
        'sessionId' => default_session_id,
        'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) }],
        'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2),
        'transactionSupportsEidas' => false
    }
    defaults.merge(options)
  end

  def stub_matching_outcome(outcome = MatchingOutcomeResponse::WAIT)
    stub_request(:get, policy_api_uri(matching_outcome_endpoint(default_session_id))).to_return(body: { 'responseProcessingStatus' => outcome }.to_json)
  end

  def x_forwarded_for
    { "X-Forwarded-For" => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  end

  def stub_response_for_rp
    response_body = {
        'postEndpoint' => '/test-rp',
        'samlMessage' => 'a saml message',
        'relayState' => 'a relay state'
    }
    stub_request(:get, saml_proxy_api_uri(response_for_rp_endpoint(default_session_id))).with(headers: x_forwarded_for).to_return(body: response_body.to_json)
  end

  def stub_error_response_for_rp
    response_body = {
        'postEndpoint' => '/test-rp',
        'samlMessage' => 'a saml message',
        'relayState' => 'a relay state'
    }
    stub_request(:get, saml_proxy_api_uri(error_response_for_rp_endpoint(default_session_id))).with(headers: x_forwarded_for).to_return(body: response_body.to_json)
  end

  def stub_cycle_three_attribute_request(name)
    cycle_three_attribute_name = { name: name }
    stub_request(:get, ida_frontend_api_uri(cycle_three_endpoint(default_session_id))).to_return(body: cycle_three_attribute_name.to_json, status: 200)
  end

  def stub_cycle_three_value_submit(value)
    cycle_three_attribute_value = { value: value, PARAM_ORIGINATING_IP => OriginatingIpStore::UNDETERMINED_IP }
    stub_request(:post, ida_frontend_api_uri(cycle_three_endpoint(default_session_id))).with(body: cycle_three_attribute_value.to_json).to_return(status: 200)
  end

  def stub_cycle_three_cancel
    stub_request(:post, ida_frontend_api_uri(cycle_three_cancel_endpoint(default_session_id))).to_return(status: 200)
  end

  def stub_api_authn_response(relay_state, response = { 'result' => 'SUCCESS', 'isRegistration' => false })
    authn_response_body = {
        PARAM_SAML_REQUEST => 'my-saml-response',
        PARAM_RELAY_STATE => relay_state,
        PARAM_IP_SEEN_BY_FRONTEND => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
    }

    stub_request(:post, saml_proxy_api_uri(IDP_AUTHN_RESPONSE_ENDPOINT))
        .with(body: authn_response_body)
        .to_return(body: response.to_json, status: 200)
  end

  def stub_api_country_authn_response(relay_state, response = { 'result' => 'SUCCESS', 'isRegistration' => false })
    authn_response_body = {
        PARAM_SAML_REQUEST => 'my-saml-response',
        PARAM_RELAY_STATE => relay_state,
        PARAM_IP_SEEN_BY_FRONTEND => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
    }

    stub_request(:post, saml_proxy_api_uri(COUNTRY_AUTHN_RESPONSE_ENDPOINT))
        .with(body: authn_response_body)
        .to_return(body: response.to_json, status: 200)
  end

  def stub_api_bad_request_response_to_country_authn_request
    stub_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
        .to_return(body: "", status: 500)
  end

  def stub_api_returns_error(code)
    stub_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
        .to_return(body: an_error_response(code).to_json, status: 500)
  end

  def stub_api_idp_list(idps = default_idps)
    stub_request(:get, config_api_uri(idp_list_endpoint(default_transaction_entity_id))).to_return(body: idps.to_json)
  end

  def stub_api_select_idp
    stub_request(:post, policy_api_uri(select_idp_endpoint(default_session_id))).to_return(status: 201)
  end

  def stub_api_no_docs_idps
    idps = [
      { 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com', 'levelsOfAssurance' => %w(LEVEL_2) },
      { 'simpleId' => 'stub-idp-no-docs', 'entityId' => 'http://idcorp.nodoc.com', 'levelsOfAssurance' => %w(LEVEL_2) },
      { 'simpleId' => 'stub-idp-two', 'entityId' => 'other-entity-id', 'levelsOfAssurance' => %w(LEVEL_2) },
      { 'simpleId' => 'stub-idp-three', 'entityId' => 'a-different-entity-id', 'levelsOfAssurance' => %w(LEVEL_2) },
    ]
    stub_api_idp_list(idps)
  end

private

  def default_session_id
    'my-session-id-cookie'
  end

  def default_transaction_id
    'test-rp'
  end

  def default_transaction_entity_id
    'http://www.test-rp.gov.uk/SAML2/MD'
  end

  def default_idps
    [
      { 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com', 'levelsOfAssurance' => %w(LEVEL_2) },
      { 'simpleId' => 'stub-idp-two', 'entityId' => 'other-entity-id', 'levelsOfAssurance' => %w(LEVEL_2) },
      { 'simpleId' => 'stub-idp-three', 'entityId' => 'a-different-entity-id', 'levelsOfAssurance' => %w(LEVEL_2) },
      { 'simpleId' => 'stub-idp-demo', 'entityId' => 'demo-entity-id', 'levelsOfAssurance' => %w(LEVEL_2) },
      { 'simpleId' => 'stub-idp-loa1', 'entityId' => 'a-different-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
    ]
  end
end

RSpec.configure do |c|
  c.include ApiTestHelper
end
