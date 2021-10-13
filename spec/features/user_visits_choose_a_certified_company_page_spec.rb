require "feature_helper"
require "api_test_helper"

describe "When the user visits the choose a certified company page" do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
  end

  context "user does a registration journey" do
    before :each do
      page.set_rack_session(page.get_rack_session.merge(transaction_simple_id: "test-rp"))
    end

    it "marks the unavailable IDP as unavailable" do
      stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one",
                                            "entityId" => "http://idcorp.com",
                                            "levelsOfAssurance" => %w(LEVEL_2),
                                            "temporarilyUnavailable" => true }])
      visit "/choose-a-certified-company"
      expect(page).to have_content t("hub.certified_companies_unavailable.heading", count: 1, company: "IDCorp")
    end

    it "includes the appropriate feedback source" do
      visit "/choose-a-certified-company"
      expect_feedback_source_to_be(page, "CHOOSE_A_CERTIFIED_COMPANY_PAGE", "/choose-a-certified-company")
    end

    it "displays recommended IDPs" do
      visit "/choose-a-certified-company"

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_title t("hub.choose_a_certified_company.heading")
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count")

      within("#recommended-idps") do
        expect(page).to have_button("Choose IDCorp")
        expect(page).to have_button("Choose Bob’s Identity Service")
        expect(page).to have_button("Carol’s Secure ID")
      end
    end

    it "doesn't display IDPs the user has previously failed to register with" do
      page.set_rack_session(page.get_rack_session.merge(idps_tried: %w[stub-idp-two]))

      visit "/choose-a-certified-company"

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content t("hub.choose_a_certified_company.idp_count")

      within("#recommended-idps") do
        expect(page).not_to have_button("Choose Bob’s Identity Service")
        expect(page).to have_button("Choose IDCorp")
        expect(page).to have_button("Carol’s Secure ID")
      end
    end

    it "redirects to the choose a certified company about page when selecting About link" do
      visit "/choose-a-certified-company"

      click_link "About IDCorp"

      expect(page).to have_current_path(choose_a_certified_company_about_path("stub-idp-one"))
    end

    it "displays the page in Welsh but actually the text is still English" do
      visit "/dewis-cwmni-ardystiedig"

      expect(page).to have_title t("hub.choose_a_certified_company.heading", locale: :cy)
      expect(page).to have_css "html[lang=cy]"
    end
  end

  context "user is from an LOA1 service" do
    before(:each) do
      stub_api_idp_list_for_registration(loa: "LEVEL_1")
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

      within("#recommended-idps") do
        expect(page).to have_button("Choose LOA1 Corp")
      end
    end

    it "unavailable LEVEL_1 recommended IDPs are marked as unavailable" do
      stub_api_idp_list_for_registration([{ "simpleId" => "stub-idp-one",
                                            "entityId" => "http://idcorp.com",
                                            "levelsOfAssurance" => %w(LEVEL_1),
                                            "temporarilyUnavailable" => true }], loa: "LEVEL_1")
      visit "/choose-a-certified-company"
      expect(page).to have_content t("hub.certified_companies_unavailable.heading", count: 1, company: "IDCorp")
    end
  end

  it "Shows recommended IDPs" do
    page.set_rack_session(transaction_simple_id: "test-rp")

    visit "/choose-a-certified-company"

    expect(page).to have_content t("hub.choose_a_certified_company.idp_count")
    within("#recommended-idps") do
      expect(page).to have_button("Choose IDCorp")
      expect(page).to have_button("Choose Bob’s Identity Service")
      expect(page).to have_button("Carol’s Secure ID")
    end
  end

  context "Google Analytics elements are rendered correctly" do
    context "when coming from an LOA2 service" do
      before :each do
        stub_api_idp_list_for_registration
        page.set_rack_session(
          transaction_simple_id: "test-rp",
          requested_loa: "LEVEL_2",
          selected_answers: {
            device_type: { device_type_other: true },
            documents: { has_valid_passport: true, has_driving_license: true, has_phone_can_app: true },
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
        stub_api_idp_list_for_registration(loa: "LEVEL_1")
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
