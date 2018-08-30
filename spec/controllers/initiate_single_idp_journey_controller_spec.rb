require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'partials/user_cookies_partial_controller'


describe InitiateSingleIdpJourneyController do
  VALID_TEST_RP = 'test-rp-no-demo'.freeze
  VALID_STUB_IDP = 'stub-idp-demo'.freeze
  UUID_ONE = 'e58394dc-6a4f-40ed-8ddd-e0e028d09da9'.freeze
  SINGLE_IDP_ENABLED_RP_LIST_MOCK = { VALID_TEST_RP => { 'url' => 'http://localhost:50300/test-saml' } }.freeze
  SINGLE_IDP_ENABLED_IDP_LIST_MOCK = [VALID_STUB_IDP].freeze

  before :each do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
  end

  context 'idp hits post providing correct parameters' do
    subject {
      post :redirect_from_idp, params: {
        serviceId: VALID_TEST_RP,
        idpEntityId: VALID_STUB_IDP,
        singleIdpJourneyIdentifier: UUID_ONE
      }
    }
    it 'should redirect to the rp page and sets a cookie when all parameters are present and valid' do
      stub_piwik_request = stub_piwik_journey_type_request_no_session(
        'SINGLE_IDP',
        'The user has started a single idp journey'
      )
      expect(subject).to redirect_to(SINGLE_IDP_ENABLED_RP_LIST_MOCK[VALID_TEST_RP]['url'])
      expect(stub_piwik_request).to have_been_made.once
      expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY])
        .to match({
          transaction_id: VALID_TEST_RP, idp_entity_id: VALID_STUB_IDP, uuid: UUID_ONE
        }.to_json)
    end
  end

  context 'idp hits post providing correct parameters and some additional parametes' do
    subject {
      post :redirect_from_idp, params: {
        serviceId: VALID_TEST_RP,
        idpEntityId: VALID_STUB_IDP,
        singleIdpJourneyIdentifier: UUID_ONE,
        randomExtraParam: UUID_ONE
      }
    }
    it 'should redirect to the rp page and sets a cookie when all parameters are present and valid and ignore incorrect parameters' do
      stub_piwik_request = stub_piwik_journey_type_request_no_session(
        'SINGLE_IDP',
        'The user has started a single idp journey'
      )
      expect(subject).to redirect_to(SINGLE_IDP_ENABLED_RP_LIST_MOCK[VALID_TEST_RP]['url'])
      expect(stub_piwik_request).to have_been_made.once
      expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY])
        .to match({
          transaction_id: VALID_TEST_RP, idp_entity_id: VALID_STUB_IDP, uuid: UUID_ONE
        }.to_json)
    end
  end

  context 'idp hits post without providing valid parameters' do
    describe 'no parameters provided' do
      subject { post :redirect_from_idp }
      it 'should redirect to the start page and not set a cookie when an incorrect rp is supplied' do
        expect(subject).to redirect_to(verify_services_path)
        expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be(nil)
      end
    end

    describe 'invalid parameter names with correct values' do
      subject {
        post :redirect_from_idp, params: {
          cat: VALID_TEST_RP,
          dog: VALID_STUB_IDP,
          rabbit: UUID_ONE
        }
      }
      it 'should redirect to the start page and not set a cookie when an incorrect rp is supplied' do
        expect(subject).to redirect_to(verify_services_path)
        expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be(nil)
      end
    end

    describe 'invalid rp (transaction id)' do
      fake_test_rp = 'fake-test-rp'
      subject {
        post :redirect_from_idp, params: {
          serviceId: fake_test_rp,
          idpEntityId: VALID_STUB_IDP,
          singleIdpJourneyIdentifier: UUID_ONE
        }
      }
      it 'should redirect to the start page and not set a cookie when an incorrect rp is supplied' do
        expect(subject).to redirect_to(verify_services_path)
        expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be(nil)
      end
    end

    describe 'invalid idp (entity idp id)' do
      fake_stub_idp = 'fake-stub-idp'
      subject {
        post :redirect_from_idp, params: {
          serviceId: VALID_TEST_RP,
          idpEntityId: fake_stub_idp,
          singleIdpJourneyIdentifier: UUID_ONE
        }
      }
      it 'should redirect to the start page and not set a cookie when an incorrect idp is supplied' do
        expect(subject).to redirect_to(verify_services_path)
        expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be(nil)
      end
    end

    describe 'uuid contains invalid characters' do
      uuid_invalid_char = '85c8:)ca-1aeb-42e1-81b8-5a5d66ef4288'.freeze
      subject {
        post :redirect_from_idp, params: {
          serviceId: VALID_TEST_RP,
          idpEntityId: VALID_STUB_IDP,
          singleIdpJourneyIdentifier: uuid_invalid_char
        }
      }
      it 'redirects to start page without cookie when uuid has invalid characters' do
        expect(subject).to redirect_to(verify_services_path)
        expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be(nil)
      end
    end

    describe 'uuid is an invalid length' do
      uuid_invalid_length = 'OooooOooow5c8d5ca-1aeb-42e1-81b8-5a5d66ef4288'
      subject {
        post :redirect_from_idp, params: {
          serviceId: VALID_TEST_RP,
          idpEntityId: VALID_STUB_IDP,
          singleIdpJourneyIdentifier: uuid_invalid_length
        }
      }
      it 'redirects to start page without cookie when uuid has invalid length' do
        expect(subject).to redirect_to(verify_services_path)
        expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be(nil)
      end
    end
  end
end
