require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'user visits further information page' do
  it 'will display title including National Insurance number' do
    stub_federation
    set_session_cookies!
    stub_cycle_three_attribute_request('NationalInsuranceNumber')

    visit further_information_path

    expect(page).to have_title 'Enter your National Insurance number - GOV.UK Verify - GOV.UK'
  end

  it 'will display title including driving licence number' do
    set_session_cookies!

    stub_cycle_three_attribute_request('drivingLicenseNumber')

    visit further_information_path

    expect(page).to have_title 'Enter your driving licence number - GOV.UK Verify - GOV.UK'
  end
end
