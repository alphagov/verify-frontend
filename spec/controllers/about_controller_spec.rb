require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "support/list_size_matcher"

describe AboutController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }

  context "LOA1" do
    before(:each) do
      stub_request(:get, CONFIG.config_api_host + "/config/transactions/enabled")
      set_session_and_cookies_with_loa("LEVEL_1")
      stub_api_idp_list_for_registration(loa: "LEVEL_1")
    end

    context "GET about" do
      subject { get :about_verify, params: { locale: "en" } }

      before(:each) do
        stub_const("IDENTITY_PROVIDER_DISPLAY_DECORATOR", identity_provider_display_decorator)
      end

      it "renders the certified companies for on the combined about view" do
        expect(identity_provider_display_decorator).to receive(:decorate_collection).with(a_list_of_size(6)).and_return([])
        expect(subject).to render_template(:how_verify_works)
      end
    end
  end

  context "LOA2" do
    before(:each) do
      stub_request(:get, CONFIG.config_api_host + "/config/transactions/enabled")
      set_session_and_cookies_with_loa("LEVEL_2")
      stub_api_idp_list_for_registration
    end

    context "GET about" do
      subject { get :about_verify, params: { locale: "en" } }

      before(:each) do
        stub_const("IDENTITY_PROVIDER_DISPLAY_DECORATOR", identity_provider_display_decorator)
      end

      it "renders the LOA2 certified companies for the combined about view" do
        expect(identity_provider_display_decorator).to receive(:decorate_collection).with(a_list_of_size(6)).and_return([])
        expect(subject).to render_template(:how_verify_works)
      end
    end

    context "GET choosing a company" do
      subject { get :about_choosing_a_company, params: { locale: "en" } }

      it "renders the choosing a company page" do
        expect(subject).to render_template(:choosing_a_company)
      end
    end

    context "GET about documents" do
      subject { get :about_documents, params: { locale: "en" } }

      it "renders the choosing a company page" do
        expect(subject).to render_template(:documents)
      end
    end

    context "GET prove identity another way" do
      subject { get :prove_your_identity_another_way, params: { locale: "en" } }

      it "renders the choosing a company page" do
        expect(subject).to render_template(:prove_your_identity_another_way)
      end
    end
  end
end
