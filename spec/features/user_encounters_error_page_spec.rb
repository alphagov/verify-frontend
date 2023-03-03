require "feature_helper"
require "api_test_helper"

RSpec.describe "user encounters error page" do
  let(:api_saml_endpoint) { saml_proxy_api_uri(new_session_endpoint) }
  let(:api_select_idp_endpoint) { policy_api_uri(select_idp_endpoint(default_session_id)) }

  it "will present the user with a list of static transactions" do
    stub_session_creation_error
    visit "/test-saml"
    click_button "saml-post"
    expect(page).to have_content t("errors.something_went_wrong.heading")
    expect(page).to have_css "#piwik-custom-url", text: "errors/generic-error"
#    t("hub.transaction_list.items").each do |transaction|
#      expect(page).to have_link transaction[:name], href: transaction[:homepage]
#    end
  end

  it "will present the user with no list of transactions if we cant read the errors" do
    allow(Rails.logger).to receive(:error)
    expect(Rails.logger).to receive(:error).with(kind_of(KeyError)).at_least(:once)
    bad_transactions_json = [
        "public" => [{ "homepage" => "http://localhost:50130/test-rp" }],
        "private" => [],
    ]
    stub_session_creation_error
    stub_request(:get, api_transactions_endpoint).to_return(body: bad_transactions_json.to_json, status: 200)
    visit "/test-saml"
    click_button "saml-post"
    expect(page).to have_content t("errors.something_went_wrong.heading")
    expect(page).to_not have_content t("hub.transaction_list.heading")
    expect(page).to have_css "#piwik-custom-url", text: "errors/generic-error"
    expect(page.status_code).to eq(500)
  end

  it "will present error page when timeout occurs in upstream systems" do
    stub_request(:post, api_saml_endpoint).to_timeout
    visit "/test-saml"
    click_button "saml-post"
    expect(page).to have_content t("errors.something_went_wrong.heading")
    expect(page).to have_css "#piwik-custom-url", text: "errors/generic-error"
    expect(page.status_code).to eq(500)
  end

  it "will present error page when standard error occurs in upstream systems" do
    e = StandardError.new("my message")
    stub_request(:post, api_saml_endpoint).to_raise(e)
    visit "/test-saml"
    click_button "saml-post"
    expect(page).to have_content t("errors.something_went_wrong.heading")
    expect(page).to have_css "#piwik-custom-url", text: "errors/generic-error"
    expect(page.status_code).to eq(500)
  end

  it "will log to raven when standard error" do
    e = StandardError.new("my message")
    expect(Raven).to receive(:capture_exception).with(e)
    stub_request(:post, api_saml_endpoint).to_raise(e)
    visit "/test-saml"
    click_button "saml-post"
    expect(page).to have_content t("errors.something_went_wrong.heading")
    expect(page.status_code).to eq(500)
  end

  it "will present something went wrong when parsable upstream error occurs and not log error" do
    expect(Raven).to_not receive(:capture_exception)
    expect(Rails.logger).to_not receive(:error)
    error_body = { errorId: "0", exceptionType: "SERVER_ERROR" }
    stub_request(:post, api_saml_endpoint).and_return(status: 500, body: error_body.to_json)
    visit "/test-saml"
    click_button "saml-post"
    expect(page).to have_content t("errors.something_went_wrong.heading")
    expect(page.status_code).to eq(500)
  end

  context "user session exists" do
    before :each do
      set_session_and_session_cookies!
    end

    context "idp" do
      before :each do
        stub_api_idp_list_for_sign_in
      end

      it "will present session error page when session error occurs in upstream systems" do
        error_body = { errorId: "0", exceptionType: "EXPECTED_SESSION_STARTED_STATE_ACTUAL_IDP_SELECTED_STATE" }
        stub_request(:post, api_saml_endpoint).to_return(body: error_body.to_json, status: 400)
        visit("/test-saml")
        click_button "saml-post"
        expect(page).to have_content t("errors.session_error.heading")
        expect(page).to have_content t("errors.session_error.security")
        expect(page).to have_css "#piwik-custom-url", text: "errors/session-error"
        expect(page.status_code).to eq(400)
      end

      it "will present a session timeout error page when the API returns session timeout" do
        stub_saml_proxy_authn_request_endpoint
        stub_policy_sign_in_process_details
        stub_transaction_details

        visit("/test-saml")
        click_button "saml-post"
        visit("/test-saml")
        click_button "saml-post-trigger-session-expiry"

        if SIGN_UPS_ENABLED
          expect(page).to have_content t("errors.session_timeout.try_again", other_ways_description: t("rps.test-rp.other_ways_description"))
          expect(page.body).to include t("errors.session_timeout.return_to_service_html")
          expect(page).to have_link t("errors.session_timeout.start_again"), href: "http://www.test-rp.gov.uk/"
        end

        expect(page).to have_css "#piwik-custom-url", text: "errors/timeout-error"
        expect(page).to have_css "a[href*=EXPIRED_ERROR_PAGE]"
        expect(page.status_code).to eq(403)
      end

      it "will present the something went wrong page in Welsh when secure cookie is invalid" do
        stub_request(:post, api_select_idp_endpoint).and_return(status: 403)
        visit sign_in_cy_path
        click_button "Welsh IDCorp"
        expect(page).to have_content t("errors.something_went_wrong.heading", locale: :cy)
        expect(page.status_code).to eq(500)
      end

      it "will present the something went wrong page when secure cookie is invalid" do
        stub_request(:post, api_select_idp_endpoint).and_return(status: 403)
        visit sign_in_path
        click_button "IDCorp"
        expect(page).to have_content t("errors.something_went_wrong.heading")
        t("hub.transaction_list.items").each do |transaction|
          expect(page).to have_link transaction[:name], href: transaction[:homepage]
        end
        expect(page).to have_css "#piwik-custom-url", text: "errors/generic-error"
        expect(page.status_code).to eq(500)
      end
    end
  end
end
