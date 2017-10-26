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

      expect(FEDERATION_REPORTER).to receive(:report_idp_registration)
                                 .with(a_kind_of(ActionDispatch::Request),
                                       bobs_identity_service_idp_name,
                                       [bobs_identity_service_idp_name],
                                       evidence.keys,
                                       idp_was_recommended)

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
      session.delete(:selected_idp_was_recommended)

      expect(FEDERATION_REPORTER).to receive(:report_idp_registration)
                                         .with(a_kind_of(ActionDispatch::Request),
                                               bobs_identity_service_idp_name,
                                               [bobs_identity_service_idp_name],
                                               evidence.keys,
                                               idp_was_recommended)

      subject
    end
  end

  context 'continuing to idp with javascript disabled when signing in' do
    bobs_identity_service = { 'simple_id' => 'stub-idp-two',
                              'entity_id' => 'http://idcorp.com',
                              'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }

    before :each do
      stub_session_idp_authn_request('<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>', 'idp-location', true)
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    end

    subject { get :sign_in, params: { locale: 'en' } }

    it 'reports idp selection details to piwik' do
      bobs_identity_service_idp_name = "Bob’s Identity Service"

      session[:selected_idp] = bobs_identity_service
      session[:selected_idp_name] = bobs_identity_service_idp_name

      expect(FEDERATION_REPORTER).to receive(:report_sign_in_idp_selection)
                                         .with(a_kind_of(ActionDispatch::Request),
                                               bobs_identity_service_idp_name)

      subject
    end
  end
end
