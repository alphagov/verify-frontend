#!/usr/bin/env ruby

require 'sinatra'
require 'json'

class StubApi < Sinatra::Base
  post '/api/session' do
    status 201
    post_to_api(JSON.parse(request.body.read)['relayState'])
  end

  get '/api/session/:session_id/idp-list' do
    '[{
        "simpleId":"stub-idp-one",
        "entityId":"http://example.com/stub-idp-one",
        "levelsOfAssurance": ["LEVEL_2"]
     }]'
  end

  put '/api/session/:session_id/select-idp' do
    '{
      "encryptedEntityId":"not-blank"
    }'
  end

  get '/api/session/:session_id/country-authn-request' do
    '{
      "location":"http://localhost:50300/test-saml",
      "samlRequest":"blah",
      "relayState":"whatever",
      "registration":false
    }'
  end

  get '/api/session/:session_id/idp-authn-request' do
    '{
      "location":"http://localhost:50300/test-saml",
      "samlRequest":"blah",
      "relayState":"whatever",
      "registration":false
    }'
  end

  put '/api/session/:session_id/idp-authn-response' do
    '{
      "idpResult":"blah",
      "isRegistration":false
    }'
  end

  get '/api/transactions' do
    '{
      "public":[{
        "simpleId":"test-rp",
        "entityId":"http://example.com/test-rp",
        "homepage":"http://example.com/test-rp",
        "loaList":["LEVEL_2"]
      }],
      "private":[],
      "transactions":[{
        "simpleId":"test-rp",
        "entityId":"http://example.com/test-rp",
        "homepage":"http://example.com/test-rp",
        "loaList":["LEVEL_2"]
        },
        {
          "simpleId": "loa1-test-rp",
          "entityId": "http://example.com/test-rp-loa1",
          "homepage":"http://example.com/test-rp-loa1",
          "loaList":["LEVEL_1","LEVEL_2"]
        }
      ]
    }'
  end

  get '/api/countries/blah' do
    '[{
        "entityId":"http://nl-proxy-node-demo.cloudapps.digital/ServiceMetadata",
        "simpleId":"NL",
        "enabled":true
      },
      {
        "entityId":"http://se-eidas.redsara.es/EidasNode/ServiceMetadata",
        "simpleId":"ES",
        "enabled":true
      },
      {
        "entityId":"http://eunode.eidastest.se/EidasNode/ServiceMetadata",
        "simpleId":"SE",
        "enabled":false
      }
     ]'
  end

  post '/api/countries/:session_id/:countryCode' do
    status 200
    ''
  end

private

  def post_to_api(relay_state)
    level_of_assurance = relay_state == 'my-loa1-relay-state' ? 'LEVEL_1' : 'LEVEL_2'
    return "{
      \"sessionId\":\"blah\",
      \"sessionStartTime\":32503680000000,
      \"transactionSimpleId\":\"test-rp\",
      \"levelsOfAssurance\":[\"#{level_of_assurance}\"],
      \"transactionSupportsEidas\": true
    }"
  end
end
