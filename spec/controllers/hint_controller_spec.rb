require 'rails_helper'
require 'controller_helper'
require 'spec_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe HintController do
  subject { get :ajax_request, params: { locale: 'en' } }
  let(:successful_idp) { get :last_successful_idp, params: { locale: 'en' } }

  context '#hint' do
    context 'user has a journey hint present' do
      it 'json object should return true' do
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
          'SUCCESS' => 'http://idcorp.com',
        }.to_json

        stub_piwik_request = stub_piwik_report_journey_hint_present('yes')

        body = JSON.parse(subject.body)
        expect(body["value"]).to eq(true)
        expect(subject.content_type).to eq("application/json")
        expect(subject).to have_http_status(200)
        expect(stub_piwik_request).to have_been_made.once
      end

      it 'json object should return true even if the value is not set' do
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
          'SUCCESS' => '',
        }.to_json

        stub_piwik_request = stub_piwik_report_journey_hint_present('yes')

        body = JSON.parse(subject.body)
        expect(body["value"]).to eq(true)
        expect(subject.content_type).to eq("application/json")
        expect(subject).to have_http_status(200)
        expect(stub_piwik_request).to have_been_made.once
      end
    end

    context 'user does not have a journey hint present' do
      it 'json object should return false' do
        stub_piwik_request = stub_piwik_report_journey_hint_present('no')
        body = JSON.parse(subject.body)
        expect(body["value"]).to eq(false)
        expect(subject.content_type).to eq("application/json")
        expect(subject).to have_http_status(200)
        expect(stub_piwik_request).to have_been_made.once
      end
    end
  end

  context '#last_successful_idp' do
    before(:each) do
      stub_api_idp_list_for_sign_in_without_session([
                                     { 'simpleId' => 'stub-idp-one',
                                       'entityId' => 'http://idcorp.com',
                                       'levelsOfAssurance' => %w(LEVEL_1) },
                                     { 'simpleId' => 'stub-idp-two',
                                       'entityId' => 'http://idcorp-two.com',
                                       'levelsOfAssurance' => %w(LEVEL_1) },
                                     { 'simpleId' => 'stub-idp-broken',
                                       'entityId' => 'http://idcorp-broken.com',
                                       'levelsOfAssurance' => %w(LEVEL_1),
                                       'temporarilyUnavailable' => true }
                                     ],
                                     'https://prod-left.tax.service.gov.uk/SAML2/PERTAX')
    end

    context 'user has previously succesfully signed in' do
      it 'json object should include simpleId and displayName' do
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
          'SUCCESS' => 'http://idcorp-two.com',
        }.to_json

        body = JSON.parse(successful_idp.body)

        expect(body['found']).to eq('true')
        expect(body['simpleId']).to eq('stub-idp-two')
        expect(body['displayName']).to eq('Bob’s Identity Service')
        expect(successful_idp.content_type).to eq("application/json")
        expect(successful_idp).to have_http_status(200)
      end

      it 'should return not found if last succesful entity ID not in available providers' do
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
          'SUCCESS' => 'http://not-available.com',
        }.to_json

        body = JSON.parse(successful_idp.body)

        expect(body['found']).to eq('false')
        expect(body.keys).not_to include('simpleId')
        expect(body.keys).not_to include('displayName')
        expect(successful_idp.content_type).to eq("application/json")
        expect(successful_idp).to have_http_status(200)
      end
    end

    context 'user has not previously successfully signed in' do
      it 'json object should not contain simpleId and displayName' do
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
          'ATTEMPT' => 'http://idcorp-two.com',
        }.to_json

        body = JSON.parse(successful_idp.body)

        expect(body['found']).to eq('false')
        expect(body.keys).not_to include('simpleId')
        expect(body.keys).not_to include('displayName')
        expect(successful_idp.content_type).to eq("application/json")
        expect(successful_idp).to have_http_status(200)
      end
    end

    context 'list of available identity providers is empty' do
      it 'json object should not contain simpleId and displayName' do
        stub_api_idp_list_for_sign_in_without_session([], 'https://prod-left.tax.service.gov.uk/SAML2/PERTAX')
        cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = {
          'SUCCESS' => 'http://idcorp-two.com',
        }.to_json

        body = JSON.parse(successful_idp.body)

        expect(body['found']).to eq('false')
        expect(body.keys).not_to include('simpleId')
        expect(body.keys).not_to include('displayName')
        expect(successful_idp.content_type).to eq("application/json")
        expect(successful_idp).to have_http_status(200)
      end
    end
  end
end
