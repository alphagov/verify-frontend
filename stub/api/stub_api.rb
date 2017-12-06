#!/usr/bin/env ruby

require 'sinatra'
require 'json'

class StubApi < Sinatra::Base
  set :protection, :except => :path_traversal

  post '/SAML2/SSO/API/RECEIVER' do
    status 200
    "\"#{JSON.parse(request.body.read)['relayState']}\"" #return session id
  end

  get '/policy/received-authn-request/:session_id/sign-in-process-details' do
    entity_id = params['session_id'] == 'my-loa1-relay-state' ? 'http://www.test-rp-loa1.gov.uk/SAML2/MD' : 'http://www.test-rp.gov.uk/SAML2/MD'
    status 200
    "{
      \"requestIssuerId\":\"#{entity_id}\",
      \"transactionSupportsEidas\":true
    }"
  end

  get '/config/transactions/:entity_id/display-data' do
    level_of_assurance = params['entity_id'] == 'http://www.test-rp-loa1.gov.uk/SAML2/MD' ? 'LEVEL_1' : 'LEVEL_2'
    status 200
    "{
      \"simpleId\":\"test-rp\",
      \"serviceHomepage\":\"www.example.com\",
      \"loaList\":[\"#{level_of_assurance}\"]
    }"
  end

  get '/config/idps/idp-list/:transaction_id/:level_of_assurance' do
    '[{
        "simpleId":"stub-idp-one",
        "entityId":"http://example.com/stub-idp-one",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
     },
     {
        "simpleId":"stub-idp-loa1",
        "entityId":"http://stub-idp-loa1.com",
        "levelsOfAssurance": ["LEVEL_1"]
     },
     {
        "simpleId":"stub-idp-loa1-with-interstitial",
        "entityId":"http://stub-idp-loa1-with-interstitial.com",
        "levelsOfAssurance": ["LEVEL_1"]
     }]'
  end

  get '/config/idps/idp-list-for-sign-in/:transaction_id' do
    '[{
        "simpleId":"stub-idp-one",
        "entityId":"http://example.com/stub-idp-one",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
     },
     {
        "simpleId":"stub-idp-loa1",
        "entityId":"http://stub-idp-loa1.com",
        "levelsOfAssurance": ["LEVEL_1"]
     },
     {
        "simpleId":"stub-idp-loa1-with-interstitial",
        "entityId":"http://stub-idp-loa1-with-interstitial.com",
        "levelsOfAssurance": ["LEVEL_1"]
     },
     {
        "simpleId":"stub-idp-two",
        "entityId":"http://example.com/stub-idp-two",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
    }]'
  end

  get '/SAML2/SSO/API/SENDER/AUTHN_REQ' do
    '{
      "postEndpoint":"http://localhost:50300/test-saml",
      "samlMessage":"blah",
      "relayState":"whatever",
      "registration":false
    }'
  end

  post '/SAML2/SSO/API/RECEIVER/EidasResponse/POST' do
    '{
      "result":"blah",
      "isRegistration":false,
      "loaAchieved":"LEVEL_2"
    }'
  end

  post '/SAML2/SSO/API/RECEIVER/Response/POST' do
    '{
       "result":"blah",
      "isRegistration":false,
      "loaAchieved":"LEVEL_2"
    }'
  end

   get '/config/transactions/enabled' do
    '[{
        "simpleId":"test-rp",
        "entityId":"http://example.com/test-rp",
        "serviceHomepage":"http://example.com/test-rp",
        "loaList":["LEVEL_2"]
      },
      {
        "simpleId": "loa1-test-rp",
        "entityId": "http://example.com/test-rp-loa1",
        "serviceHomepage":"http://example.com/test-rp-loa1",
        "loaList":["LEVEL_1","LEVEL_2"]
      }]'
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
