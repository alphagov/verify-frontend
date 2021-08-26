require "feature_helper"
require "api_test_helper"
require "piwik_test_helper"

RSpec.describe "When the user is sent to the paused registration page" do
  let(:idp_display_name) { "IDCorp" }
  let(:idp_display_name_welsh) { "Welsh IDCorp" }
  let(:rp_entity_id) { "http://www.test-rp.gov.uk/SAML2/MD" }
  let(:originating_ip) { "<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>" }
  let(:idp_entity_id) { "http://idcorp.com" }
  let(:encrypted_entity_id) { "an-encrypted-entity-id" }

  let(:select_idp_stub_request) {
    stub_session_select_idp_request(
      encrypted_entity_id,
      PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id, PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
      PolicyEndpoints::PARAM_REGISTRATION => false, PolicyEndpoints::PARAM_REQUESTED_LOA => LevelOfAssurance::LOA2
    )
  }

  before(:each) do
    stub_api_idp_list_for_registration
    set_selected_idp_in_session(entity_id: idp_entity_id, simple_id: "stub-idp-one")
    set_journey_hint_cookie(idp_entity_id, "PENDING", "en", rp_entity_id)
    stub_translations
  end

  context "and has a session" do
    context "and is verifying for a service WITH a headless start page" do
      it "renders page with a button linking to the services headless start page" do
        stub_transaction_details
        set_session_and_session_cookies!
        visit "/paused"

        expect(page).to have_link(t("hub.paused_registration.with_session.continue_verifying", idp_name: idp_display_name), href: "http://www.test-rp.gov.uk/success")
      end
    end
    context "and verifying for a service WITHOUT a headless start page" do
      it "renders page with a button linking to the services home page" do
        stub_transaction_details(headlessStartpage: nil)
        set_session_and_session_cookies!

        visit "/paused"

        expect(page).to have_link(t("hub.paused_registration.with_session.continue_verifying", idp_name: idp_display_name), href: "http://www.test-rp.gov.uk/")
      end
    end
    context "and is verifying for a service WITH a headless start page in Welsh" do
      it "renders page with a button linking to the services headless start page" do
        stub_transaction_details
        set_session_and_session_cookies!
        visit "/wedi-oedi"

        expect(page).to have_link(t("hub.paused_registration.with_session.continue_verifying", locale: "cy", idp_name: idp_display_name_welsh), href: "http://www.test-rp.gov.uk/success")
      end
    end
    context "and verifying for a service WITHOUT a headless start page in Welsh" do
      it "renders page with a button linking to the services home page" do
        stub_transaction_details(headlessStartpage: nil)
        set_session_and_session_cookies!

        visit "/wedi-oedi"

        expect(page).to have_link(t("hub.paused_registration.with_session.continue_verifying", locale: "cy", idp_name: idp_display_name_welsh), href: "http://www.test-rp.gov.uk/")
      end
    end
  end

  context "and does not have a session" do
    context "and is verifying for a service WITH headless start page" do
      it "renders page with a button linking to the services headless start page" do
        stub_transaction_details
        visit "/paused"

        expect(page).to have_link(t("hub.paused_registration.with_session.continue_verifying", idp_name: idp_display_name), href: "http://www.test-rp.gov.uk/success")
      end
    end
    context "and verifying for a service WITHOUT a headless start page" do
      it "renders page with a button linking to the services home page" do
        stub_transaction_details(headlessStartpage: nil)
        visit "/paused"

        expect(page).to have_link(t("hub.paused_registration.with_session.continue_verifying", idp_name: idp_display_name), href: "http://www.test-rp.gov.uk/")
      end
    end
    context "and is verifying for a service WITH headless start page in Welsh" do
      it "renders page with a button linking to the services headless start page" do
        stub_transaction_details
        visit "/wedi-oedi"

        expect(page).to have_link(t("hub.paused_registration.with_session.continue_verifying", locale: "cy", idp_name: idp_display_name_welsh), href: "http://www.test-rp.gov.uk/success")
      end
    end
    context "and verifying for a service WITHOUT a headless start page in Welsh" do
      it "renders page with a button linking to the services home page" do
        stub_transaction_details(headlessStartpage: nil)
        visit "/wedi-oedi"

        expect(page).to have_link(t("hub.paused_registration.with_session.continue_verifying", locale: "cy", idp_name: idp_display_name_welsh), href: "http://www.test-rp.gov.uk/")
      end
    end
  end
end
