require "feature_helper"
require "api_test_helper"

describe "When the user visits the choose a certified company page" do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration(default_idps)
  end

  context "user has two docs and a mobile" do
    selected_answers = {
        device_type: { device_type_other: true },
        documents: { passport: true, driving_licence: true },
        phone: { mobile_phone: true },
    }
    before :each do
      page.set_rack_session(
        transaction_simple_id: "test-rp",
        selected_answers: selected_answers,
      )
    end

    it "marks the unavailable IDP as unavailable" do
      stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one",
                                            "entityId" => "http://idcorp.com",
                                            "levelsOfAssurance" => %w(LEVEL_2),
                                            "temporarilyUnavailable" => true }])
      visit "/choose-a-certified-company"
      expect(page).to have_content t("hub.certified_companies_unavailable.title", count: 1, company: "IDCorp")
    end

    it "includes the appropriate feedback source" do
      visit "/choose-a-certified-company"

      expect_feedback_source_to_be(page, "CHOOSE_A_CERTIFIED_COMPANY_PAGE", "/choose-a-certified-company")
    end

    it "displays recommended IDPs" do
      visit "/choose-a-certified-company"

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count_html", company_count: "3 companies")
      within("#matching-idps") do
        expect(page).to have_button("Choose IDCorp")
      end
    end

    it "displays only one IDP and saves it in the cookie" do
      stub_const("THROTTLING_ENABLED", true)
      expect(cookie_value(CookieNames::THROTTLING)).to be_nil
      visit "/choose-a-certified-company"

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count_html", company_count: "1 company")
      expect(cookie_value(CookieNames::THROTTLING)).not_to be_nil
    end

    it "displays only one IDP if the throttling cookie is corrupted" do
      idp_in_cookie = "non-existing-idp"
      visit "/test-throttling-cookie/#{idp_in_cookie}"
      stub_const("THROTTLING_ENABLED", true)

      visit "/choose-a-certified-company"

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count_html", company_count: "1 company")
      expect(cookie_value(CookieNames::THROTTLING)).not_to eq(idp_in_cookie)
    end

    it "displays only one IDP from the throttling cookie" do
      idp_in_cookie = "idps_stub-idp-two"
      visit "/test-throttling-cookie/#{idp_in_cookie}"
      stub_const("THROTTLING_ENABLED", true)

      visit "/choose-a-certified-company"

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count_html", company_count: "1 company")
      within("#matching-idps") do
        expect(page).to have_button("Choose Bob’s Identity Service")
      end
    end

    it "displays all IDPs if last status is FAILED" do
      idp_in_cookie = "idps_stub-idp-two"
      visit "/test-throttling-cookie/#{idp_in_cookie}"
      stub_const("THROTTLING_ENABLED", true)
      set_journey_hint_cookie(nil, "FAILED")

      visit "/choose-a-certified-company"

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count_html", company_count: "3 companies")

      within("#matching-idps") do
        expect(page).to have_button("Choose Bob’s Identity Service")
        expect(page).to have_button("Choose Carol’s Secure ID")
        expect(page).to have_button("Choose IDCorp")
      end
    end

    it "does not show an IDP if the IDP profile has a subset of the user evidence, but not an exact match" do
      additional_documents = selected_answers[:documents].clone
      additional_documents[:driving_licence] = false
      page.set_rack_session(
        transaction_simple_id: "test-rp",
        selected_answers: {
          selected_answers: additional_documents,
          phone: selected_answers[:phone],
          device_type: { device_type_other: true },
        },
      )

      visit "/choose-a-certified-company"

      within("#matching-idps") do
        expect(page).to_not have_button("Choose IDCorp")
      end
    end

    it "redirects to the choose a certified company about page when selecting About link" do
      visit "/choose-a-certified-company"

      click_link "About IDCorp"

      expect(page).to have_current_path(choose_a_certified_company_about_path("stub-idp-one"))
    end

    it "displays the page in Welsh" do
      visit "/dewis-cwmni-ardystiedig"

      expect(page).to have_title t("hub.choose_a_certified_company.title", locale: :cy)
      expect(page).to have_css "html[lang=cy]"
    end
  end

  context "user is from an LOA1 service" do
    before(:each) do
      stub_api_idp_list_for_registration(default_idps, "LEVEL_1")
      page.set_rack_session(
        transaction_simple_id: "test-rp",
        requested_loa: "LEVEL_1",
        selected_answers: {
          device_type: { device_type_other: true },
          documents: { passport: true, driving_licence: true },
          phone: { mobile_phone: true },
        },
      )
    end

    it "only LEVEL_1 recommended IDPs are displayed" do
      visit "/choose-a-certified-company"

      expect(page).to have_current_path(choose_a_certified_company_path)

      within("#matching-idps") do
        expect(page).to have_button("Choose LOA1 Corp")
      end
    end

    it "unavailable LEVEL_1 recommended IDPs are marked as unavailable" do
      stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one",
                                           "entityId" => "http://idcorp.com",
                                           "levelsOfAssurance" => %w(LEVEL_1),
                                           "temporarilyUnavailable" => true }], "LEVEL_1")
      visit "/choose-a-certified-company"
      expect(page).to have_content t("hub.certified_companies_unavailable.title", count: 1, company: "IDCorp")
    end
  end

  it "displays no IDPs if no recommendations" do
    page.set_rack_session(
      transaction_simple_id: "test-rp",
      selected_answers: {
        device_type: { device_type_other: true },
        documents: { passport: false },
      },
    )

    visit "/choose-a-certified-company"

    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page).to_not have_css("#non-matching-idps")
    expect(page).to have_content t("hub.choose_a_certified_company.idp_count_html", company_count: "no companies")
  end

  it "recommends some IDPs with a recommended profile, hides non-recommended profiles, and omits non-matching profiles" do
    stub_api_no_docs_idps
    page.set_rack_session(
      transaction_simple_id: "test-rp",
      selected_answers: {
        device_type: { device_type_other: true },
        documents: { driving_licence: true },
        phone: { mobile_phone: true },
      },
    )

    visit "/choose-a-certified-company"

    expect(page).to have_content t("hub.choose_a_certified_company.idp_count_html", company_count: "2 companies")
    within("#matching-idps") do
      expect(page).to have_button("Choose No Docs IDP")
      expect(page).to have_button("Choose IDCorp")
      expect(page).to_not have_button("Bob’s Identity Service")
    end

    within("#non-matching-idps") do
      expect(page).to have_button("Bob’s Identity Service")
    end

    expect(page).to_not have_button("Choose Carol’s Secure ID")
  end

  context "IDP profile is in a demo period" do
    selected_answers = {
      device_type: { device_type_other: true },
      documents: { passport: true, driving_licence: true },
      phone: { mobile_phone: true },
    }

    it "shows the IDP if the RP is not protected" do
      page.set_rack_session(
        transaction_simple_id: "test-rp",
        selected_answers: selected_answers,
      )

      visit "/choose-a-certified-company"

      within("#matching-idps") do
        expect(page).to have_button("Choose Bob’s Identity Service")
      end
    end

    it "shows the IDP as unlikely if the RP is protected" do
      page.set_rack_session(
        transaction_simple_id: "test-rp-no-demo",
        selected_answers: selected_answers,
      )

      visit "/choose-a-certified-company"

      within("#matching-idps") do
        expect(page).to_not have_button("Choose Bob’s Identity Service")
      end

      within("#non-matching-idps") do
        expect(page).to have_button("Choose Bob’s Identity Service")
      end
    end
  end

  context "Google Analytics elements are rendered correctly" do
    context "when coming from an LOA2 service" do
      before :each do
        stub_api_idp_list_for_registration(default_idps, "LEVEL_2")
        page.set_rack_session(
          transaction_simple_id: "test-rp",
          requested_loa: "LEVEL_2",
          selected_answers: {
            device_type: { device_type_other: true },
            documents: { passport: true, driving_licence: true },
            phone: { mobile_phone: true },
          },
          )
      end

      it "should render GA elements on choose certified company page" do
        visit "/choose-a-certified-company"

        expect(page).to have_css "span#cross-gov-ga-tracker-id", text: "UA-XXXXX-Y"
      end

      it "should not render GA elements on about page" do
        visit "/choose-a-certified-company"

        click_link "About IDCorp"

        expect(page).to_not have_css "span#cross-gov-ga-tracker-id", text: "UA-XXXXX-Y"
      end
    end

    context "when coming from an LOA1 service" do
      before :each do
        stub_api_idp_list_for_registration(default_idps, "LEVEL_1")
        page.set_rack_session(
          transaction_simple_id: "test-rp",
          requested_loa: "LEVEL_1",
          selected_answers: {
            device_type: { device_type_other: true },
            documents: { passport: true, driving_licence: true },
            phone: { mobile_phone: true },
          },
          )
      end

      it "should render GA elements on choose certified company page" do
        visit "/choose-a-certified-company"

        expect(page).to have_css "span#cross-gov-ga-tracker-id", text: "UA-XXXXX-Y"
      end

      it "should not render GA elements on about page" do
        visit "/choose-a-certified-company"

        click_link "About IDCorp"

        expect(page).to_not have_css "span#cross-gov-ga-tracker-id", text: "UA-XXXXX-Y"
      end
    end
  end
end
