#!/usr/bin/env ruby

require 'sinatra'
require 'json'

class StubApi < Sinatra::Base
  set :protection, :except => :path_traversal
  post '/api/session' do
    status 201
    post_to_api(JSON.parse(request.body.read)['relayState'])
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
     },
     {
        "simpleId":"stub-idp-loa1-onboarding",
        "entityId":"http://stub-idp-loa1-onboarding.com",
        "levelsOfAssurance": ["LEVEL_1"]
      }]'
  end

  put '/api/session/:session_id/select-idp' do
    '{
      "encryptedEntityId":"not-blank"
    }'
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

private

  def post_to_api(relay_state)
    level_of_assurance = relay_state == 'my-loa1-relay-state' ? 'LEVEL_1' : 'LEVEL_2'
    return "{
      \"sessionId\":\"blah\",
      \"sessionStartTime\":32503680000000,
      \"transactionSimpleId\":\"test-rp\",
      \"transactionEntityId\":\"http://www.test-rp.gov.uk/SAML2/MD\",
      \"levelsOfAssurance\":[\"#{level_of_assurance}\"],
      \"transactionSupportsEidas\": true
    }"
  end
end
