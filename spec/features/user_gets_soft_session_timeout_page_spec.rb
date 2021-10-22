require "feature_helper"
require "api_test_helper"

RSpec.describe "When the user visits a page that triggers an API call when the session has soft timed out" do
  before(:each) do
    set_session_and_session_cookies!
    set_journey_type_in_session(JourneyType::REGISTRATION)
    stub_api_idp_list_for_registration
    stub_api_select_idp
  end

  it "should render the soft session timeout page when SESSION_TIMEOUT received from the API and have a correct link" do
    stub_api_returns_error("SESSION_TIMEOUT")

    visit choose_a_certified_company_path
    click_button("Choose IDCorp")

    expect(page).to have_content t "errors.something_went_wrong.heading"
    expect(page).to have_content t "errors.session_timeout.start_again"
    expect(page).to have_link(href: "http://www.test-rp.gov.uk/", class: "govuk-button")
  end
end
