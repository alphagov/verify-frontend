require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe RedirectToIdpController do
  before :each do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    set_session_and_cookies_with_loa('LEVEL_2')
    session[:selected_idp_was_recommended] = [true, false].sample
  end

  context 'continuing to idp with javascript disabled' do
    bobs_identity_service = { 'simple_id' => 'stub-idp-two',
                              'entity_id' => 'http://idcorp.com',
                              'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
    before :each do
      stub_session_idp_authn_request('<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>', 'idp-location', true)
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    end

    subject { get :register, params: { locale: 'en' } }

    it 'reports idp registration details to piwik' do
      bobs_identity_service_idp_name = "Bob’s Identity Service"
      idp_was_recommended = '(recommended)'
      evidence = { driving_licence: true, passport: true }

      session[:selected_idp] = bobs_identity_service
      session[:selected_idp_name] = bobs_identity_service_idp_name
      session[:selected_idp_names] = [bobs_identity_service_idp_name]
      session[:selected_answers] = { 'documents' => evidence }
      session[:selected_idp_was_recommended] = idp_was_recommended
      session[:user_segments] = ['test-segment']

      expect(FEDERATION_REPORTER).to receive(:report_idp_registration)
        .with(current_transaction: a_kind_of(Display::RpDisplayData),
              request: a_kind_of(ActionDispatch::Request),
              idp_name: bobs_identity_service_idp_name,
              idp_name_history: [bobs_identity_service_idp_name],
              evidence: evidence.keys,
              recommended: idp_was_recommended,
              user_segments: ['test-segment'])

      subject
    end

    it "reports idp registration and doesn't error out if idp_was_recommended key not present" do
      bobs_identity_service_idp_name = "Bob’s Identity Service"
      idp_was_recommended = '(idp recommendation key not set)'
      evidence = { driving_licence: true, passport: true }

      session[:selected_idp] = bobs_identity_service
      session[:selected_idp_name] = bobs_identity_service_idp_name
      session[:selected_idp_names] = [bobs_identity_service_idp_name]
      session[:selected_answers] = { 'documents' => evidence }
      session[:user_segments] = ['test-segment']
      session.delete(:selected_idp_was_recommended)

      expect(FEDERATION_REPORTER).to receive(:report_idp_registration)
                                         .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                               request: a_kind_of(ActionDispatch::Request),
                                               idp_name: bobs_identity_service_idp_name,
                                               idp_name_history: [bobs_identity_service_idp_name],
                                               evidence: evidence.keys,
                                               recommended: idp_was_recommended,
                                               user_segments: ['test-segment'])

      subject
    end
  end

  context 'reports user idp attempt' do
    describe '#register' do
      bobs_identity_service = { 'simple_id' => 'stub-idp-two',
                                'entity_id' => 'http://idcorp.com',
                                'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }

      before :each do
        stub_session_idp_authn_request('<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>', 'idp-location', true)
        stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
      end

      subject { get :register, params: { locale: 'en' } }

      it 'reports idp registration attempt details to piwik' do
        bobs_identity_service_idp_name = "Bob’s Identity Service"

        session[:selected_idp] = bobs_identity_service
        session[:selected_idp_name] = bobs_identity_service_idp_name
        session[:user_segments] = ['test-segment']
        session[:transaction_simple_id] = 'test-rp'
        session[:journey_type] = 'registration'


        expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt)
                                           .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                                 request: a_kind_of(ActionDispatch::Request),
                                                 idp_name: bobs_identity_service_idp_name,
                                                 user_segments: ['test-segment'],
                                                 transaction_simple_id: 'test-rp',
                                                 attempt_number: 1,
                                                 journey_type: 'registration')
        subject
      end

      it 'reports idp second attempt details to piwik' do
        bobs_identity_service_idp_name = "Bob’s Identity Service"

        session[:selected_idp] = bobs_identity_service
        session[:selected_idp_name] = bobs_identity_service_idp_name
        session[:user_segments] = ['test-segment']
        session[:transaction_simple_id] = 'test-rp'
        session[:attempt_number] = 1
        session[:journey_type] = 'registration'


        expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt)
                                           .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                                 request: a_kind_of(ActionDispatch::Request),
                                                 idp_name: bobs_identity_service_idp_name,
                                                 user_segments: ['test-segment'],
                                                 transaction_simple_id: 'test-rp',
                                                 attempt_number: 2,
                                                 journey_type: 'registration')
        subject
      end
    end

    describe '#sign_in' do
      bobs_identity_service = { 'simple_id' => 'stub-idp-two',
                                'entity_id' => 'http://idcorp.com',
                                'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
      bobs_identity_service_idp_name = 'Bob’s Identity Service'

      before :each do
        stub_session_idp_authn_request('<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>', 'idp-location', false)
        stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))

        session[:selected_idp] = bobs_identity_service
        session[:selected_idp_name] = bobs_identity_service_idp_name
      end

      subject { get :sign_in, params: { locale: 'en' } }

      it 'reports idp sign in attempt details to piwik' do
        session[:user_segments] = ['test-segment']
        session[:transaction_simple_id] = 'test-rp'
        session[:journey_type] = 'sign-in'

        expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt)
                                           .with(current_transaction: a_kind_of(Display::RpDisplayData),
                                                 request: a_kind_of(ActionDispatch::Request),
                                                 idp_name: bobs_identity_service_idp_name,
                                                 user_segments: ['test-segment'],
                                                 transaction_simple_id: 'test-rp',
                                                 attempt_number: 1,
                                                 journey_type: 'sign-in')
        subject
      end
    end

    context 'continuing to idp with javascript disabled when signing in' do
      bobs_identity_service = { 'simple_id' => 'stub-idp-two',
                                'entity_id' => 'http://idcorp.com',
                                'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
      bobs_identity_service_idp_name = 'Bob’s Identity Service'

      before :each do
        stub_session_idp_authn_request('<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>', 'idp-location', false)
        stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))

        session[:selected_idp] = bobs_identity_service
        session[:selected_idp_name] = bobs_identity_service_idp_name
      end

      subject { get :sign_in, params: { locale: 'en' } }

      it 'reports idp selection details to piwik' do
        expect(FEDERATION_REPORTER).to receive(:report_sign_in_idp_selection)
                                           .with(a_kind_of(Display::RpDisplayData),
                                                 a_kind_of(ActionDispatch::Request),
                                                 bobs_identity_service_idp_name)

        subject
      end

      context 'and with the journey hint session param' do
        before :each do
          session[:user_followed_journey_hint] = true
        end

        it 'reports idp selection details to piwik' do
          expect(FEDERATION_REPORTER).to receive(:report_sign_in_idp_selection_after_journey_hint)
                                             .with(a_kind_of(Display::RpDisplayData),
                                                   a_kind_of(ActionDispatch::Request),
                                                   bobs_identity_service_idp_name,
                                                   true)

          subject
        end
      end

      context 'and with the journey hint session param suggesting hint ignored' do
        before :each do
          session[:user_followed_journey_hint] = false
        end

        it 'reports idp selection details to piwik' do
          expect(FEDERATION_REPORTER).to receive(:report_sign_in_idp_selection_after_journey_hint)
                                             .with(a_kind_of(Display::RpDisplayData),
                                                   a_kind_of(ActionDispatch::Request),
                                                   bobs_identity_service_idp_name,
                                                   false)

          subject
        end
      end
    end
  end
end
