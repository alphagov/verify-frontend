require "rails_helper"
require "controller_helper"
require "api_test_helper"

describe FurtherInformationController do
  subject { get :index, params: { locale: "en" } }

  before :each do
    set_selected_idp(entity_id: "http://idcorp.com", simple_id: "stub-idp-one")
    set_session_and_cookies_with_loa(LevelOfAssurance::LOA2)
    stub_cycle_three_attribute_request("NationalInsuranceNumber")
  end

  it "renders the further information page" do
    expect(subject).to render_template(:index)
  end

  it "redirects to the timeout page when the assertion has expired" do
    session[:assertion_expiry] = 1.minute.ago.to_s
    expect(subject).to redirect_to further_information_timeout_path
  end

  it "does not redirect to the timeout page when the assertion has not expired yet" do
    session[:assertion_expiry] = 1.minute.from_now.to_s
    expect(subject).to render_template(:index)
  end

  it "redirects to timeout page when attempting to submit an expired assertion" do
    session[:assertion_expiry] = 1.minute.ago.to_s
    post :submit, params: { locale: "en" }
    expect(response).to redirect_to further_information_timeout_path
  end
end
