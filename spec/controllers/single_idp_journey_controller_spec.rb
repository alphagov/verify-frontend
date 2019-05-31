require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'
require 'partials/user_cookies_partial_controller'

describe SingleIdpJourneyController do
  VALID_TEST_RP = 'http://www.test-rp.gov.uk/SAML2/MD'.freeze
  VALID_STUB_IDP = 'http://idcorp.com'.freeze
  UUID_ONE = 'e58394dc-6a4f-40ed-8ddd-e0e028d09da9'.freeze
  SINGLE_IDP_ENABLED_RP_LIST_MOCK = { VALID_TEST_RP => { 'url' => 'http://localhost:50130/test-saml' } }.freeze
  SINGLE_IDP_ENABLED_IDP_LIST_MOCK = [VALID_STUB_IDP].freeze

  before :each do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    stub_transactions_for_single_idp_list
    stub_api_idp_list_for_single_idp_journey
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
      expect(Rails.logger).to receive(:info).with("Successful Single IDP redirect to RP URL #{SINGLE_IDP_ENABLED_RP_LIST_MOCK[VALID_TEST_RP]['url']} from IdpId #{VALID_STUB_IDP} with uuid #{UUID_ONE}")
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
      expect(Rails.logger).to receive(:info).with("Successful Single IDP redirect to RP URL #{SINGLE_IDP_ENABLED_RP_LIST_MOCK[VALID_TEST_RP]['url']} from IdpId #{VALID_STUB_IDP} with uuid #{UUID_ONE}")
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
        expect(Rails.logger).to receive(:error).with(/Single IDP parameter serviceId is missing/)
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
        expect(Rails.logger).to receive(:error).with(/Single IDP parameter serviceId is missing/)
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
        expect(Rails.logger).to receive(:error).with(/Could not get the RP URL for single IDP with transaction_id fake-test-rp/)
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
        expect(Rails.logger).to receive(:error).with(/The IDP is not valid or disabled for transaction_id http:\/\/www.test-rp.gov.uk\/SAML2\/MD and idp_entity_id fake-stub-idp/)
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
        expect(Rails.logger).to receive(:error).with(/Single IDP UUID #{Regexp.quote(uuid_invalid_char)} not valid/)
        expect(subject).to redirect_to(verify_services_path)
        expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be(nil)
      end
    end

    describe 'uuid is an invalid length' do
      uuid_invalid_length = '5oooo5ooow5c8d5ca-1aeb-42e1-81b8-5a5d66ef4288'
      subject {
        post :redirect_from_idp, params: {
          serviceId: VALID_TEST_RP,
          idpEntityId: VALID_STUB_IDP,
          singleIdpJourneyIdentifier: uuid_invalid_length
        }
      }
      it 'redirects to start page without cookie when uuid has invalid length' do
        expect(Rails.logger).to receive(:error).with(/Single IDP UUID #{Regexp.quote(uuid_invalid_length)} not valid/)
        expect(subject).to redirect_to(verify_services_path)
        expect(cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY]).to be(nil)
      end
    end
  end

  context '#index' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_transactions_for_single_idp_list
      stub_api_idp_list_for_single_idp_journey
    end

    subject { get :continue_to_your_idp, params: { locale: 'en' } }

    it 'should render /continue-to-your-idp if all is valid' do
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        idp_entity_id: VALID_STUB_IDP,
        uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      stub_piwik_event = stub_piwik_report_single_idp_success(VALID_TEST_RP, UUID_ONE)

      expect(subject).to render_template(:continue_to_your_idp)
      expect(stub_piwik_event).to have_been_made.once
    end

    it 'should redirect to /start if cookie is missing' do
      stub_piwik_event = stub_piwik_report_single_idp_invalid_cookie
      expect(Rails.logger).to receive(:warn).with(/Single IDP cookies was not found or was malformed/)
      expect(subject).to redirect_to(start_path)
      expect(stub_piwik_event).to(have_been_made.once)
    end

    it 'should redirect to /start if cookie is corrupted' do
      stub_piwik_event = stub_piwik_report_single_idp_invalid_cookie
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = "blah"
      expect(Rails.logger).to receive(:warn).with(/Single IDP cookies was not found or was malformed/)
      expect(subject).to redirect_to(start_path)
      expect(stub_piwik_event).to(have_been_made.once)
    end

    it 'should redirect to /start if cookie is missing some fields' do
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      expect(Rails.logger).to receive(:error).with(/Single IDP cookie value for idp_entity_id is missing/)
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if idp is not enabled' do
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        idp_entity_id: 'disabled-idp',
        uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      expect(Rails.logger).to receive(:error).with(/The IDP is not valid or disabled for transaction_id http:\/\/www.test-rp.gov.uk\/SAML2\/MD and idp_entity_id disabled-idp/)
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if IDP is not available' do
      stub_api_idp_list_for_single_idp_journey(VALID_TEST_RP,
                                               [{ 'simpleId' => 'stub-idp-one',
                                                  'entityId' => 'http://idcorp.com',
                                                  'levelsOfAssurance' => %w(LEVEL_2),
                                                  'temporarilyUnavailable' => true }])
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        idp_entity_id: VALID_STUB_IDP,
        uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      expect(Rails.logger).to receive(:info).with(/unavailable/)
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if rp is not enabled' do
      stub_api_idp_list_for_single_idp_journey('disabled-rp')
      single_idp_cookie = {
        transaction_id: 'disabled-rp',
        idp_entity_id: VALID_STUB_IDP,
        uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      expect(Rails.logger).to receive(:info).with(/The value of the Single IDP cookie does not match the session value of http:\/\/www.test-rp.gov.uk\/SAML2\/MD for transaction_id disabled-rp/)
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if uuid is in a wrong format' do
      single_idp_cookie = {
        transaction_id: VALID_TEST_RP,
        idp_entity_id: VALID_STUB_IDP,
        uuid: 'wrong-uuid'
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json
      expect(Rails.logger).to receive(:error).with(/Single IDP UUID wrong-uuid not valid/)
      expect(subject).to redirect_to(start_path)
    end

    it 'should redirect to /start if rp in cookie does not match the one in the session' do
      stub_api_idp_list_for_single_idp_journey('test-rp-noc3')
      stub_piwik_event = stub_piwik_report_single_idp_service_mismatch('test-rp-noc3', VALID_TEST_RP, UUID_ONE)
      single_idp_cookie = {
          transaction_id: 'test-rp-noc3',
          idp_entity_id: VALID_STUB_IDP,
          uuid: UUID_ONE
      }
      cookies.encrypted[CookieNames::VERIFY_SINGLE_IDP_JOURNEY] = single_idp_cookie.to_json

      expect(Rails.logger).to receive(:info).with(/The value of the Single IDP cookie does not match the session value of http:\/\/www.test-rp.gov.uk\/SAML2\/MD for transaction_id test-rp-noc3/)
      expect(subject).to redirect_to(start_path) # call to subject is made here – NB retrospective expect statements (e.g. have_been_made) must come after this line.
      expect(stub_piwik_event).to(have_been_made.once)
    end
  end

  context '#continue' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_transactions_for_single_idp_list
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

    describe 'with invalid idp (entity idp id is empty)' do
      it 'should redirect to the start page' do
        post :continue, params: { locale: 'en', entity_id: '' }

        expect(subject).to redirect_to start_path
      end
    end

    describe 'with invalid idp (entity idp id missing)' do
      it 'should redirect to the start page' do
        post :continue, params: { locale: 'en' }

        expect(subject).to redirect_to start_path
      end
    end
  end

  context '#continue_ajax' do
    before :each do
      set_session_and_cookies_with_loa('LEVEL_2')
      stub_transactions_for_single_idp_list
      stub_api_idp_list_for_single_idp_journey
    end

    it 'should handle missing cookie' do
      valid_idp = {
        'simple_id' => 'stub-idp-one',
        'entity_id' => VALID_STUB_IDP,
        'levels_of_assurance' => %w(LEVEL_1 LEVEL_2)
      }

      stub_api_select_idp
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
      stub_request(:get, saml_proxy_api_uri('/SAML2/SSO/API/SENDER/AUTHN_REQ?sessionId=my-session-id-cookie')).to_return(
        body: {
          postEndpoint: 'location',
          samlMessage: 'a-saml-request',
          relayState: 'a-relay-state',
          registration: false
        }.to_json,
        status: 200
      )

      set_selected_idp(valid_idp)
      post :continue_ajax, params: { locale: 'en', entityId: VALID_STUB_IDP }

      expect(response).to have_http_status :ok
    end
  end

  context "#rp_start_page" do
    before :each do
      stub_transactions_list
      stub_translations
    end

    it 'renders 404 error if invalid RP passed' do
      get :rp_start_page, params: { locale: 'en', transaction_simple_id: 'bad-rp' }

      expect(subject).to render_template 'errors/404'
    end

    it 'renders 404 error if RP does not have singleIdpStartPage content defined' do
      get :rp_start_page, params: { locale: 'en', transaction_simple_id: 'test-rp-noc3' }

      expect(subject).to render_template 'errors/404'
    end

    it 'renders correct page if RP has singleIdpStartPage content defined' do
      get :rp_start_page, params: { locale: 'en', transaction_simple_id: 'test-rp' }

      expect(subject).to render_template 'rp_start_page'
    end
  end
end
