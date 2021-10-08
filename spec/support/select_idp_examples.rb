# frozen_string_literal: true

require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"

shared_examples "select_idp" do |journey_type, method_name, stub_idp_list_method, stub_piwik_method, reporter_method, check_error_handling = true|
  IDP_ENTITY_ID ||= "http://idcorp.com"
  IDP_SIMPLE_ID ||= "stub-idp-one"
  IDP_DISPLAY_NAME ||= "IDCorp"
  TRANSACTION_ID ||= "test-rp"

  let(:registration) { [JourneyType::REGISTRATION, JourneyType::RESUMING].include? journey_type }

  shared_examples "select_idp_tests" do |loa|
    before(:each) do
      stub_requests(journey_type, loa, stub_idp_list_method, stub_piwik_method)
    end

    it "renders to the redirect to IDP page" do
      post method_name, params: { locale: "en", entity_id: IDP_ENTITY_ID }
      expect(subject).to render_template "shared/redirect_to_idp"
    end

    it "sets selected IDP in user session" do
      post method_name, params: { locale: "en", entity_id: IDP_ENTITY_ID }
      expect(session[:selected_provider].entity_id).to eql(IDP_ENTITY_ID)
      expect(session[:selected_provider].simple_id).to eql(IDP_SIMPLE_ID)
    end

    it "reports IDP attempt" do
      expect_piwik_reports(journey_type, reporter_method)
      post method_name, params: { locale: "en", entity_id: IDP_ENTITY_ID }
    end

    it "returns 404 page if IDP is non-existent" do
      post method_name, params: { locale: "en", entity_id: "http://notanidp.com" }
      expect(subject).to render_template "errors/something_went_wrong"
      expect(response).to have_http_status :not_found
    end

    if check_error_handling
      it "returns 400 if 'entity_id' param is not present" do
        post method_name, params: { locale: "en" }
        expect(subject).to render_template "errors/something_went_wrong"
        expect(response).to have_http_status :bad_request
      end
    end

    context "with JS enabled" do
      subject { post "#{method_name}_ajax", params: { locale: "en", entityId: IDP_ENTITY_ID } }

      it "sets selected IDP in user session" do
        subject
        expect(subject).to have_http_status 200
        expect(session[:selected_provider].entity_id).to eql(IDP_ENTITY_ID)
      end

      it "reports IDP attempt" do
        expect_piwik_reports(journey_type, reporter_method)
        subject
        expect(subject).to have_http_status 200
      end
    end
  end

  context "LOA1" do
    include_examples "select_idp_tests", "LEVEL_1"
  end

  context "LOA2" do
    include_examples "select_idp_tests", "LEVEL_2"
  end

  def stub_requests(journey_type, loa, stub_idp_list_method, stub_piwik_method)
    stub_api_select_idp
    stub_session_idp_authn_request(registration: registration)
    set_session_and_cookies_with_loa(loa, journey_type: journey_type)
    stub_piwik_report_user_idp_attempt(IDP_DISPLAY_NAME, TRANSACTION_ID, journey_type, loa: loa)
    method(stub_piwik_method).(IDP_DISPLAY_NAME, loa)

    stub_idps_method = method(stub_idp_list_method)
    params = select_params(stub_idps_method, { loa: loa })
    stub_idps_method.(**params)
  end

  def expect_piwik_reports(journey_type, reporter_method)
    params = {
      current_transaction: instance_of(Display::RpDisplayData),
      request: kind_of(ActionDispatch::Request),
      idp_name: IDP_DISPLAY_NAME,
      idp_name_history: [IDP_DISPLAY_NAME],
      attempt_number: 1,
      journey_type: journey_type.downcase,
      hint_followed: nil,
    }

    expect(FEDERATION_REPORTER).to receive(:report_user_idp_attempt).
      with(select_params(FEDERATION_REPORTER.method(:report_user_idp_attempt), params))

    expect(FEDERATION_REPORTER).to receive(reporter_method).
      with(select_params(FEDERATION_REPORTER.method(reporter_method), params))
  end

  def select_params(method, params)
    param_names = method.parameters.map { |_, name| name }
    params.select { |name, _| param_names.include? name }
  end
end
