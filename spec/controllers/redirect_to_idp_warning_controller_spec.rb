require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe RedirectToIdpWarningController do
  before :each do
    stub_api_select_idp
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    set_session_and_cookies_with_loa('LEVEL_2')
    session[:selected_idp_was_recommended] = [true, false].sample
  end

  context 'renders idp logos' do
    subject { get :index, params: { locale: 'en' } }

    it 'warning page when idp selected' do
      session[:selected_idp] = { 'simple_id' => 'stub-idp-two',
                                 'entity_id' => 'http://idcorp.com',
                                 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }

      expect(subject).to render_template(:redirect_to_idp_warning)
    end

    it 'error page when no idp selected' do
      session[:selected_idp] = {}

      expect(subject).to render_template('errors/something_went_wrong')
    end
  end

  context 'continuing to idp' do
    bobs_identity_service = { 'simple_id' => 'stub-idp-two',
                              'entity_id' => 'http://idcorp.com',
                              'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
    before :each do
      stub_api_select_idp
      stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    end

    subject { post :continue, params: { locale: 'en' } }

    it 'redirects to idp website' do
      session[:selected_idp] = bobs_identity_service

      expect(subject).to redirect_to redirect_to_idp_path
    end

    it 'reports idp registration details to piwik' do
      bobs_identity_service_idp_name = "Bob’s Identity Service"
      idp_was_recommended = '(recommended)'
      evidence = { driving_licence: true, passport: true }

      session[:selected_idp] = bobs_identity_service
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

    it 'reports idp registration and doesn\'t error out if idp_was_recommended key not present' do
      bobs_identity_service_idp_name = "Bob’s Identity Service"
      idp_was_recommended = '(idp recommendation key not set)'
      evidence = { driving_licence: true, passport: true }

      session[:selected_idp] = bobs_identity_service
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
end
