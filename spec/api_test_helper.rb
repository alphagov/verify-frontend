module ApiTestHelper
  include SessionEndpoints

  def api_uri(path)
    URI.join(CONFIG.api_host, File.join('/api/', path))
  end

  def api_transactions_endpoint
    api_uri('transactions')
  end

  def api_countries_endpoint(session_id)
    api_uri('countries/' + session_id)
  end

  def stub_transactions_list
    transactions = {
      'transactions' => [
        { 'simpleId' => 'test-rp',      'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp', 'loaList' => ['LEVEL_2'] },
        { 'simpleId' => 'test-rp-noc3', 'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp-noc3', 'loaList' => ['LEVEL_2'] },
        { 'simpleId' => 'headless-rp',  'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/headless-rp', 'loaList' => ['LEVEL_2'] }
      ]
    }
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
    stub_request(:get, api_uri(country_authn_request_endpoint(default_session_id)))
        .with(headers: { 'X_FORWARDED_FOR' => originating_ip })
        .to_return(body: a_country_authn_request(country_location, registration).to_json)
  end

  def a_country_authn_request(location, registration)
    {
        'location' => location,
        'samlRequest' => 'a-saml-request',
        'relayState' => 'a-relay-state',
        'registration' => registration
    }
  end

  def stub_session_select_idp_request(encrypted_entity_id, request_body = {})
    stub = stub_request(:put, api_uri(select_idp_endpoint(default_session_id)))
    if request_body.any?
      stub = stub.with(body: request_body)
    end
    stub.to_return(body: { 'encryptedEntityId' => encrypted_entity_id }.to_json)
  end

  def stub_session_idp_authn_request(originating_ip, idp_location, registration)
    stub_request(:get, api_uri(idp_authn_request_endpoint(default_session_id)))
        .with(headers: { 'X_FORWARDED_FOR' => originating_ip })
        .to_return(body: an_idp_authn_request(idp_location, registration).to_json)
  end

  def an_idp_authn_request(location, registration)
    {
        'location' => location,
        'samlRequest' => 'a-saml-request',
        'relayState' => 'a-relay-state',
        'registration' => registration
    }
  end

  def an_error_response(code)
    {
        type: code
    }
  end

  def stub_api_saml_endpoint(options = {})
    authn_request_body = {
        PARAM_SAML_REQUEST => 'my-saml-request',
        PARAM_RELAY_STATE => 'my-relay-state',
        PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
    }
    stub_request(:post, api_uri('session')).with(body: authn_request_body).to_return(body: stub_api_session(options).to_json, status: 201)
  end

  def stub_api_session(options = {})
    {
        'transactionSimpleId' => 'test-rp',
        'sessionStartTime' => '32503680000000',
        'sessionId' => default_session_id,
        'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) }],
        'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2),
        'transactionSupportsEidas' => options.fetch(:transaction_supports_eidas, false)
    }
  end

  def stub_matching_outcome(outcome = MatchingOutcomeResponse::WAIT)
    stub_request(:get, api_uri(matching_outcome_endpoint(default_session_id))).to_return(body: { 'outcome' => outcome }.to_json)
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
    stub_request(:get, api_uri(response_for_rp_endpoint(default_session_id))).with(headers: x_forwarded_for).to_return(body: response_body.to_json)
  end

  def stub_error_response_for_rp
    response_body = {
        'postEndpoint' => '/test-rp',
        'samlMessage' => 'a saml message',
        'relayState' => 'a relay state'
    }
    stub_request(:get, api_uri(error_response_for_rp_endpoint(default_session_id))).with(headers: x_forwarded_for).to_return(body: response_body.to_json)
  end

  def stub_cycle_three_attribute_request(name)
    cycle_three_attribute_name = { name: name }
    stub_request(:get, api_uri(cycle_three_endpoint(default_session_id))).to_return(body: cycle_three_attribute_name.to_json, status: 200)
  end

  def stub_cycle_three_value_submit(value)
    cycle_three_attribute_value = { value: value, PARAM_ORIGINATING_IP => OriginatingIpStore::UNDETERMINED_IP }
    stub_request(:post, api_uri(cycle_three_endpoint(default_session_id))).with(body: cycle_three_attribute_value.to_json).to_return(status: 200)
  end

  def stub_cycle_three_cancel
    stub_request(:post, api_uri(cycle_three_cancel_endpoint(default_session_id))).to_return(status: 200)
  end

  def stub_api_authn_response(relay_state, response = { 'idpResult' => 'SUCCESS', 'isRegistration' => false })
    authn_response_body = {
        PARAM_SAML_RESPONSE => 'my-saml-response',
        PARAM_RELAY_STATE => relay_state,
        PARAM_ORIGINATING_IP => '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'
    }

    stub_request(:put, api_uri(idp_authn_response_endpoint(default_session_id)))
        .with(body: authn_response_body)
        .to_return(body: response.to_json, status: 200)
  end

  def stub_api_returns_error(code)
    stub_request(:get, api_uri(idp_authn_request_endpoint(default_session_id)))
        .to_return(body: an_error_response(code).to_json, status: 500)
  end

  def stub_api_idp_list(idps = default_idps)
    stub_request(:get, api_uri(idp_list_endpoint(default_session_id))).to_return(body: idps.to_json)
  end

  def stub_api_no_docs_idps
    idps = [
      { 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
      { 'simpleId' => 'stub-idp-no-docs', 'entityId' => 'http://idcorp.nodoc.com', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
      { 'simpleId' => 'stub-idp-two', 'entityId' => 'other-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
      { 'simpleId' => 'stub-idp-three', 'entityId' => 'a-different-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
    ]
    stub_api_idp_list(idps)
  end

private

  def default_session_id
    'my-session-id-cookie'
  end

  def default_idps
    [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
     { 'simpleId' => 'stub-idp-two', 'entityId' => 'other-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
     { 'simpleId' => 'stub-idp-three', 'entityId' => 'a-different-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
     { 'simpleId' => 'stub-idp-demo', 'entityId' => 'demo-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
     { 'simpleId' => 'stub-idp-loa1', 'entityId' => 'a-different-entity-id', 'levelsOfAssurance' => %w(LEVEL_1) }
    ]
  end
end

RSpec.configure do |c|
  c.include ApiTestHelper
end
