def api_uri(path)
  URI.join(API_HOST, '/api/', path)
end

def api_transactions_endpoint
  api_uri('transactions')
end

def stub_transactions_list
  transactions = {
    'public' => [
      { 'simpleId' => 'test-rp', 'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp' },
      { 'simpleId' => 'test-rp-noc3', 'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp-noc3' }
    ],
    'private' => [
      { 'simpleId' => 'headless-rp', 'entityId' => 'some-entity-id' },
    ]
  }
  stub_request(:get, api_transactions_endpoint).to_return(body: transactions.to_json, status: 200)
end

def stub_federation(idp_entity_id = 'http://idcorp.com')
  idps = [
    { 'simpleId' => 'stub-idp-one', 'entityId' => idp_entity_id },
    { 'simpleId' => 'stub-idp-two', 'entityId' => 'other-entity-id' },
    { 'simpleId' => 'stub-idp-three', 'entityId' => 'a-different-entity-id' }
  ]
  body = { 'idps' => idps, 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-entity-id' }
  stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
end

def stub_federation_no_docs
  idps = [
    { 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com' },
    { 'simpleId' => 'stub-idp-no-docs', 'entityId' => 'http://idcorp.nodoc.com' }
  ]
  body = { 'idps' => idps, 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-id' }
  stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
end

def stub_session_select_idp_request(encrypted_entity_id, request_body = {})
  stub = stub_request(:put, api_uri('session/select-idp'))
  if request_body.any?
    stub = stub.with(body: request_body)
  end
  stub.to_return(body: { 'encryptedEntityId' => encrypted_entity_id }.to_json)
end

def stub_session_idp_authn_request(originating_ip, idp_location, registration)
  stub_request(:get, api_uri('session/idp-authn-request'))
    .with(query: { 'originatingIp' => originating_ip }).to_return(body: an_idp_authn_response(idp_location, registration).to_json)
end

def an_idp_authn_response(location, registration)
  {
    'location' => location,
    'samlRequest' => 'a-saml-request',
    'relayState' => 'a-relay-state',
    'registration' => registration
  }
end
