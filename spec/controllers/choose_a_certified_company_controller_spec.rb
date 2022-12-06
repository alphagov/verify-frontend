require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "piwik_test_helper"
require "select_idp_examples"

describe ChooseACertifiedCompanyController do
  context "LOA1" do
    let(:stub_idp_loa1) {
      {
        simpleId: "stub-idp-loa1",
        entityId: "http://idcorp-loa1.com",
        levelsOfAssurance: %w(LEVEL_1 LEVEL_2),
      }.freeze
    }

    context "#index" do
      before :each do
        stub_api_idp_list_for_registration([stub_idp_loa1], loa: "LEVEL_1")
      end

      if SIGN_UPS_ENABLED
        it "renders IDP list" do
          set_session_and_cookies_with_loa("LEVEL_1", "test-rp")

          expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection).once do |idps|
            idps.each { |idp| expect(idp.levels_of_assurance).to include "LEVEL_1" }
          end

          get :index, params: { locale: "en" }
          expect(subject).to render_template(:choose_a_certified_company)
        end
      end
    end

    context "#about" do
      it "returns 404 error if no display data exists for IDP" do
        set_session_and_cookies_with_loa("LEVEL_1")
        stub_api_idp_list_for_registration(loa: "LEVEL_1")

        get :about, params: { locale: "en", company: "unknown-idp" }

        expect(subject).to render_template "errors/something_went_wrong"
        expect(response).to have_http_status :not_found
      end
    end
  end

  context "LOA2" do
    before(:each) do
      stub_api_select_idp
      set_session_and_cookies_with_loa("LEVEL_2")
      stub_api_idp_list_for_registration
    end

    context "#index" do
      if SIGN_UPS_ENABLED
        it "renders the IDP picker page" do
          expect(IDENTITY_PROVIDER_DISPLAY_DECORATOR).to receive(:decorate_collection) do |idps|
            idps.each { |idp| expect(idp.levels_of_assurance).to include "LEVEL_2" }
          end

          get :index, params: { locale: "en" }

          expect(subject).to render_template(:choose_a_certified_company)
        end
      end
    end

    context "#about" do
      it "returns 404 page if no display data exists for IDP" do
        get :about, params: { locale: "en", company: "unknown-idp" }

        expect(subject).to render_template "errors/something_went_wrong"
        expect(response).to have_http_status :not_found
      end
    end
  end

  context "select IDP" do
    include_examples "select_idp", JourneyType::REGISTRATION, :select_idp,
                     :stub_api_idp_list_for_registration, :stub_piwik_idp_registration, :report_idp_registration
  end
end
