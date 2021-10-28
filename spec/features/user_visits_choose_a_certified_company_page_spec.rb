require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

describe "When the user visits the choose a certified company page" do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
  end

  context "redirect to IDP" do
    let(:encrypted_entity_id) { "an-encrypted-entity-id" }
    let(:idp_entity_id) { "http://idcorp.com" }
    let(:idp_display_name) { "IDCorp" }

    context "with JS enabled", js: true do
      it "will redirect the user to the IDP" do
        stub_session_idp_authn_request(registration: true)
        stub_session_select_idp_request(encrypted_entity_id)
        set_session_and_session_cookies!(cookie_hash: create_cookie_hash_with_piwik_session)

        visit choose_a_certified_company_path

        expect_any_instance_of(ChooseACertifiedCompanyController).to receive(:select_idp_ajax).and_call_original
        click_button t("hub.choose_a_certified_company.choose_idp", display_name: idp_display_name)

        expect(page).to have_current_path(ApiTestHelper::IDP_LOCATION)
        expect(page).to have_content("SAML Request is 'a-saml-request'")
        expect(page).to have_content("relay state is 'a-relay-state'")
        expect(page).to have_content("registration is 'true'")
        expect(cookie_value("verify-front-journey-hint")).to_not be_nil

        expect(a_request(:post, policy_api_uri(select_idp_endpoint(default_session_id)))
                 .with(body: { PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id,
                               PolicyEndpoints::PARAM_PRINCIPAL_IP => ApiTestHelper::ORIGINATING_IP,
                               PolicyEndpoints::PARAM_REGISTRATION => true,
                               PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
                               PolicyEndpoints::PARAM_PERSISTENT_SESSION_ID => instance_of(String),
                               PolicyEndpoints::PARAM_JOURNEY_TYPE => "registration",
                               PolicyEndpoints::PARAM_VARIANT => nil })).to have_been_made.once

        expect(a_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
                 .with(headers: { "X_FORWARDED_FOR" => ApiTestHelper::ORIGINATING_IP })).to have_been_made.once

        expect(stub_piwik_report_user_idp_attempt(idp_display_name, default_transaction_id, JourneyType::REGISTRATION)).to have_been_made.once
        expect(stub_piwik_idp_registration(idp_display_name)).to have_been_made.once

        expect(page.get_rack_session_key("selected_provider")["identity_provider"])
          .to include("entity_id" => idp_entity_id, "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_2))
      end
    end

    it "redirects the user to IDP on clicking Continue" do
      stub_api_select_idp
      stub_session_idp_authn_request(registration: true)

      visit choose_a_certified_company_path

      click_button t("hub.choose_a_certified_company.choose_idp", display_name: idp_display_name)
      expect(page).to have_current_path choose_a_certified_company_path
      expect(page).to have_title t("hub.redirect_to_idp.heading")

      click_button t("navigation.continue")
      expect(page).to have_http_status 200
      expect(page).to have_current_path(ApiTestHelper::IDP_LOCATION)
      expect(page).to have_content("SAML Request is 'a-saml-request'")
      expect(page).to have_content("relay state is 'a-relay-state'")
      expect(page).to have_content("registration is 'true'")
      expect(cookie_value("verify-front-journey-hint")).to_not be_nil
    end
  end

  context "user is trying to access an LOA2 service" do
    before :each do
      page.set_rack_session transaction_simple_id: "test-rp"
    end

    it "marks the unavailable IDP as unavailable" do
      stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one",
                                            "entityId" => "http://idcorp.com",
                                            "levelsOfAssurance" => %w(LEVEL_2),
                                            "temporarilyUnavailable" => true }])
      visit choose_a_certified_company_path
      expect(page).to have_content t("hub.certified_companies_unavailable.heading", count: 1, company: "IDCorp")
    end

    it "doesn't display IDPs disconnecting for registration" do
      stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one",
                                            "entityId" => "http://idcorp.com",
                                            "levelsOfAssurance" => %w(LEVEL_2),
                                            "provideRegistrationUntil" => "1990-01-01T00:00:00+00:00" }])

      visit choose_a_certified_company_path
      expect(page).not_to have_content t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name"))
    end

    it "includes the appropriate feedback source" do
      visit choose_a_certified_company_path
      expect_feedback_source_to_be(page, "CHOOSE_A_CERTIFIED_COMPANY_PAGE", choose_a_certified_company_path)
    end

    it "displays recommended IDPs" do
      visit choose_a_certified_company_path

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_title t("hub.choose_a_certified_company.heading")
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count")

      within("#recommended-idps") do
        expect(page).to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name")))
        expect(page).to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-two.name")))
        expect(page).to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-three.name")))
      end
    end

    it "doesn't display IDPs the user has previously failed to register with" do
      page.set_rack_session(page.get_rack_session.merge(idps_tried: %w[stub-idp-two]))

      visit choose_a_certified_company_path

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count")

      within("#recommended-idps") do
        expect(page).not_to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-two.name")))
        expect(page).to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name")))
        expect(page).to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-three.name")))
      end
    end

    it "redirects to the choose a certified company about page when selecting About link" do
      visit choose_a_certified_company_path

      click_link "About IDCorp"

      expect(page).to have_current_path(choose_a_certified_company_about_path("stub-idp-one"))
    end

    it "displays the page in Welsh" do
      visit "/dewis-cwmni-ardystiedig"

      expect(page).to have_title t("hub.choose_a_certified_company.heading", locale: :cy)
      expect(page).to have_css "html[lang=cy]"
    end
  end

  context "user is trying to access an LOA1 service" do
    before(:each) do
      stub_api_idp_list_for_registration(loa: "LEVEL_1")
      page.set_rack_session(
        transaction_simple_id: "test-rp",
        requested_loa: "LEVEL_1",
      )
    end

    it "only LEVEL_1 recommended IDPs are displayed" do
      visit choose_a_certified_company_path

      expect(page).to have_current_path(choose_a_certified_company_path)

      within("#recommended-idps") do
        expect(page).to have_button("Choose LOA1 Corp")
      end
    end

    it "unavailable LEVEL_1 recommended IDPs are marked as unavailable" do
      stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one",
                                            "entityId" => "http://idcorp.com",
                                            "levelsOfAssurance" => %w(LEVEL_1),
                                            "temporarilyUnavailable" => true }],
                                         loa: "LEVEL_1")
      visit choose_a_certified_company_path
      expect(page).to have_content t("hub.certified_companies_unavailable.heading", count: 1, company: "IDCorp")
    end
  end

  it "Shows recommended IDPs" do
    page.set_rack_session transaction_simple_id: "test-rp"

    visit choose_a_certified_company_path

    expect(page).to have_content t("hub.choose_a_certified_company.idp_count")
    within("#recommended-idps") do
      expect(page).to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-one.name")))
      expect(page).to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-two.name")))
      expect(page).to have_button(t("hub.choose_a_certified_company.choose_idp", display_name: t("idps.stub-idp-three.name")))
    end
  end

  context "Google Analytics elements are rendered correctly" do
    context "when coming from an LOA2 service" do
      before :each do
        stub_api_idp_list_for_registration
        page.set_rack_session(
          transaction_simple_id: "test-rp",
          requested_loa: "LEVEL_2",
        )
      end

      it "should render GA elements on choose certified company page" do
        visit choose_a_certified_company_path

        expect(page).to have_css "span#cross-gov-ga-tracker-id", text: "UA-XXXXX-Y"
      end

      it "should not render GA elements on about page" do
        visit choose_a_certified_company_path

        click_link "About IDCorp"

        expect(page).to_not have_css "span#cross-gov-ga-tracker-id", text: "UA-XXXXX-Y"
      end
    end

    context "when coming from an LOA1 service" do
      before :each do
        stub_api_idp_list_for_registration(loa: "LEVEL_1")
        page.set_rack_session(
          transaction_simple_id: "test-rp",
          requested_loa: "LEVEL_1",
        )
      end

      it "should render GA elements on choose certified company page" do
        visit choose_a_certified_company_path

        expect(page).to have_css "span#cross-gov-ga-tracker-id", text: "UA-XXXXX-Y"
      end

      it "should not render GA elements on about page" do
        visit choose_a_certified_company_path

        click_link "About IDCorp"

        expect(page).to_not have_css "span#cross-gov-ga-tracker-id", text: "UA-XXXXX-Y"
      end
    end
  end
end
