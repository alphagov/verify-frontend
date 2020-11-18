require "rails_helper"
require "controller_helper"
require "api_test_helper"
require "support/list_size_matcher"

describe AboutLoaController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }

  context "LOA1" do
    before(:each) do
      stub_request(:get, CONFIG.config_api_host + "/config/transactions/enabled")
      set_session_and_cookies_with_loa("LEVEL_1")
      stub_api_idp_list_for_registration(default_idps, "LEVEL_1")
    end

    context "GET about" do
      subject { get :index, params: { locale: "en" } }

      before(:each) do
        stub_const("IDENTITY_PROVIDER_DISPLAY_DECORATOR", identity_provider_display_decorator)
      end

      it "renders the certified companies for on the combined about view" do
        expect(identity_provider_display_decorator).to receive(:decorate_collection).with(a_list_of_size(7)).and_return([])
        expect(subject).to render_template(:about_combined_LOA)
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
      subject { get :index, params: { locale: "en" } }

      before(:each) do
        stub_const("IDENTITY_PROVIDER_DISPLAY_DECORATOR", identity_provider_display_decorator)
      end

      it "renders the LOA2 certified companies for the combined about view" do
        expect(identity_provider_display_decorator).to receive(:decorate_collection).with(a_list_of_size(7)).and_return([])
        expect(subject).to render_template(:about_combined_LOA)
      end
    end
  end
end
