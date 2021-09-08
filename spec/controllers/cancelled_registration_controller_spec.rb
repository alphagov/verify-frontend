require "rails_helper"
require "controller_helper"
require "api_test_helper"

describe CancelledRegistrationController do
  subject { get :index, params: { locale: "en" } }

  before :each do
    set_selected_idp(entity_id: "http://idcorp.com", simple_id: "stub-idp-one", levels_of_assurance: [LevelOfAssurance::LOA1, LevelOfAssurance::LOA2])
  end

  it "renders the cancelled registration LOA1 template when LEVEL_1 is the requested LOA" do
    set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)

    expect(subject).to render_template(:cancelled_registration)
  end

  it "renders the cancelled registration LOA2 template when LEVEL_2 is the requested LOA" do
    set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)

    expect(subject).to render_template(:cancelled_registration)
  end
end
