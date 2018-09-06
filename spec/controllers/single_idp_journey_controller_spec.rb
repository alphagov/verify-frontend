require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'partials/user_cookies_partial_controller'


describe SingleIdpJourneyController do
  VALID_TEST_RP = 'test-rp-no-demo'.freeze
  VALID_STUB_IDP = 'http://idcorp.com'.freeze
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

  context '#index' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
    end

    subject { get :continue_to_your_idp, params: { locale: 'en' } }
    it 'should render /continue-to-your-idp if all is valid' do
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        idp_entity_id: VALID_STUB_IDP,
        uuid: UUID_ONE
      }

      stub_api_idp_list_for_single_idp_journey
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json

      expect(subject).to render_template(:continue_to_your_idp)
    end

    it 'should redirect to /start if cookie is missing' do
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if cookie is corrupted' do
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = "blah"
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if cookie is missing some fields' do
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if idp is not enabled' do
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        idp_entity_id: 'disabled-idp',
        uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if rp is not enabled' do
      single_idp_cookie = {
        transaction_id: 'disabled-rp',
        idp_entity_id: VALID_STUB_IDP,
        uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      # TODO with HUB-271
      # expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if uuid is in a wrong format' do
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        idp_entity_id: VALID_STUB_IDP,
        uuid: 'wrong-uuid'
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      expect(subject).to redirect_to(start_path)
    end
  end


  context '#continue' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_api_idp_list_for_single_idp_journey
    end

    it 'should redirect to IDP website' do
      valid_idp = {
        'simple_id' => 'stub-idp-one',
        'entity_id' => VALID_STUB_IDP,
        'levels_of_assurance' => %w(LEVEL_1 LEVEL_2)
      }

      stub_api_select_idp
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))

      set_selected_idp(valid_idp)
      post :continue, params: { locale: 'en', entity_id: VALID_STUB_IDP }

      expect(subject).to redirect_to redirect_to_single_idp_path
    end
  end
end
