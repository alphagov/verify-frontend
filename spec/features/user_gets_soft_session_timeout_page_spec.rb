require "feature_helper"
require "api_test_helper"

RSpec.describe "When the user visits a page that triggers an API call when the session has soft timed out" do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
  end

  it "should render the soft session timeout page when SESSION_TIMEOUT received from the API and have a correct link" do
    stub_api_returns_error("SESSION_TIMEOUT")
    visit redirect_to_idp_register_path
    expect(page).to have_link(href: "http://www.test-rp.gov.uk/", class: "govuk-button")
  end

  it "should render the soft session timeout page when SESSION_TIMEOUT received from the API when continue on failed is enabled and have a correct link" do
    set_session!(transaction_simple_id: "test-rp-with-continue-on-fail")
    stub_api_returns_error("SESSION_TIMEOUT")
    visit redirect_to_idp_register_path
    expect(page).to have_link(href: "/redirect-to-service/error", class: "govuk-button")
  end
end
