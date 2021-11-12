require "rails_helper"
require "controller_helper"
require "api_test_helper"

describe CancelledRegistrationController do
  let(:identity_provider_display_decorator) { double(:IdentityProviderDisplayDecorator) }
  subject { get :index, params: { locale: "en" } }

  before :each do
    stub_request(:get, CONFIG.config_api_host + "/config/transactions/enabled")
    set_selected_idp("entity_id" => "http://idcorp.com", "simple_id" => "stub-idp-one", "levels_of_assurance" => %w(LEVEL_1 LEVEL_2))
  end

  it "renders the cancelled registration LOA1 template when LEVEL_1 is the requested LOA" do
    set_session_and_cookies_with_loa("LEVEL_1")
    stub_api_idp_list_for_registration(loa: "LEVEL_1")

    expect(subject).to render_template(:cancelled_registration)
  end

  it "renders the cancelled registration LOA2 template when LEVEL_2 is the requested LOA" do
    set_session_and_cookies_with_loa("LEVEL_2")
    stub_api_idp_list_for_registration(loa: "LEVEL_2")

    expect(subject).to render_template(:cancelled_registration)
  end
end
