#!/usr/bin/env ruby

require 'sinatra'

class StubApi < Sinatra::Base
  post '/api/session' do
    status 201
    '{
      "sessionId":"blah",
      "sessionStartTime":32503680000000,
      "transactionSimpleId":"test-rp",
      "idps":[{
        "simpleId":"stub-idp-one",
        "entityId":"http://example.com/stub-idp-one"
      }],
      "levelsOfAssurance":["LEVEL_2"],
      "transactionSupportsEidas": true
    }'
  end

  get '/api/session/:session_id/federation' do
    '{
      "idps":[{
        "simpleId":"stub-idp-one",
        "entityId":"http://example.com/stub-idp-one"
      }]
    }'
  end

  put '/api/session/:session_id/select-idp' do
    '{
      "encryptedEntityId":"not-blank"
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
        "homepage":"http://example.com/test-rp"
      }],
      "private":[]
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
end
