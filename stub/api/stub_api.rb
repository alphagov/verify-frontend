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
      \"requestIssuerId\":\"#{entity_id}\"
    }"
  end

  get '/config/transactions/:entity_id/display-data' do
    level_of_assurance = params['entity_id'] == 'http://www.test-rp-loa1.gov.uk/SAML2/MD' ? 'LEVEL_1' : "LEVEL_2"
    status 200
    "{
      \"simpleId\":\"test-rp\",
      \"serviceHomepage\":\"http://localhost:50300/test-saml\",
      \"loaList\":[\"#{level_of_assurance}\"],
      \"headlessStartpage\":\"http://example.com/success\"
    }"
  end

  get '/config/transactions/:entity_id/translations/:locale' do
    if params['locale'] == 'en'
      '{
        "name":"test GOV.UK Verify user journeys",
        "rpName":"EN: Test RP",
        "analyticsDescription":"analytics description for test-rp",
        "otherWaysText":"<p>If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul class=\"govuk-list govuk-list--bullet\"><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        "otherWaysDescription":"test GOV.UK Verify user journeys",
        "tailoredText":"<p>External data source: EN: This is tailored text for test-rp</p>",
        "taxonName":"Benefits",
        "customFailHeading":"This is a custom fail page."
      }'
    else
      '{
        "name":"test GOV.UK Verify user journeys",
        "rpName":"CY: Test RP",
        "analyticsDescription":"analytics description for test-rp",
        "otherWaysText":"<p>If you can’t verify your identity using GOV.UK Verify, you can test GOV.UK Verify user journeys <a href=\"http://www.example.com\">here</a>.</p><p>Tell us your:</p><ul class=\"govuk-list govuk-list--bullet\"><li>name</li><li>age</li></ul><p>Include any other relevant details if you have them.</p>",
        "otherWaysDescription":"test GOV.UK Verify user journeys",
        "tailoredText":"<p>External data source: CY: This is tailored text for test-rp</p>",
        "taxonName":"Benefits",
        "customFailHeading":"This is a custom fail page in welsh."
      }'
    end
  end

  get '/config/idps/idp-list-for-registration/:transaction_id/:level_of_assurance' do
    if params['level_of_assurance'] == 'LEVEL_1'
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
    else
    '[{
        "simpleId":"stub-idp-one",
        "entityId":"http://example.com/stub-idp-one",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
     },
     {
        "simpleId":"stub-idp-two",
        "entityId":"http://example.com/stub-idp-two",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
     },
     {
        "simpleId":"stub-idp-three",
        "entityId":"http://example.com/stub-idp-three",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
     }]'
    end
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
     },
     {
        "simpleId":"stub-idp-three",
        "entityId":"http://example.com/stub-idp-three",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
     }]'
  end

  get '/config/idps/idp-list-for-single-idp/:transaction_id' do
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
     },
     {
        "simpleId":"stub-idp-three",
        "entityId":"http://example.com/stub-idp-three",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
     },
     {
        "simpleId":"stub-idp-one",
        "entityId":"http://idcorp.com",
        "levelsOfAssurance": ["LEVEL_1", "LEVEL_2"]
     }]'
  end

  get '/SAML2/SSO/API/SENDER/AUTHN_REQ' do
    '{
      "postEndpoint":"/test-idp-request-endpoint",
      "samlMessage":"blah",
      "relayState":"whatever",
      "registration":false
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
        "serviceHomepage":"http://example.com/test-rp",
        "loaList":["LEVEL_2"],
        "headlessStartpage":"http://example.com/test-rp/success"
      },
      {
        "simpleId": "loa1-test-rp",
        "serviceHomepage":"http://example.com/test-rp-loa1",
        "loaList":["LEVEL_1","LEVEL_2"],
        "headlessStartpage":"http://example.com/test-rp-loa1/success"
      },
      {
        "simpleId": "loa2-loa1-test-rp",
        "serviceHomepage":"http://example.com/test-rp-loa2-loa1",
        "loaList":["LEVEL_2","LEVEL_1"],
        "headlessStartpage":"http://example.com/test-rp-loa2-loa1/success"
      }]'
   end

  get '/config/transactions/single-idp-enabled-list' do
    '[{
        "simpleId":"test-rp",
        "redirectUrl":"http://example.com/test-saml",
        "loaList":["LEVEL_2"],
        "entityId":"http://www.test-rp.gov.uk/SAML2/MD"
      },
      {
        "simpleId": "loa1-test-rp",
        "redirectUrl":"http://example.com/test-rp-loa1",
        "loaList":["LEVEL_1","LEVEL_2"],
        "entityId": "http://example.com/test-rp-loa1"
      }],
      {
        "simpleId": "loa2-loa1-test-rp",
        "redirectUrl":"http://example.com/test-rp-loa1",
        "loaList":["LEVEL_2","LEVEL_1",],
        "entityId": "http://example.com/test-rp-loa2-loa1"
      }]'
  end

  get '/config/certificates/:entity_id/certs/signing' do
    '[{
        "issuerId":"http://www.test-rp.gov.uk/SAML2/MD",
        "certificate":"certificate-value",
        "keyUse":"Signing",
        "federationEntityType":"RP"
     }]'
  end

  get '/config/certificates/:entity_id/certs/encryption' do
    '{
        "issuerId":"http://www.test-rp.gov.uk/SAML2/MD",
        "certificate":"certificate-value",
        "keyUse":"Encryption",
        "federationEntityType":"RP"
     }'
  end

  post '/policy/received-authn-request/my-relay-state/select-identity-provider' do
    status 200
    ''
  end

  get '/service-status' do
    status 200
    ''
  end
end
