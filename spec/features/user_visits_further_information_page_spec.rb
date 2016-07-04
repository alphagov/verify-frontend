require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'user visits further information page' do
  before(:each) do
    stub_federation
    page.set_rack_session(transaction_simple_id: 'test-rp')
    set_session_cookies!
  end

  it 'will display title including National Insurance number' do
    stub_cycle_three_attribute_request('NationalInsuranceNumber')

    visit further_information_path

    expect(page).to have_content I18n.t('rps.test-rp.name').capitalize
    expect(page).to have_content I18n.t('hub.further_information.first_time')
    expect(page).to have_content I18n.t('hub.further_information.cycle_three_input_label', cycle_three_name: 'National Insurance number')
    expect(page).to have_title 'Enter your National Insurance number - GOV.UK Verify - GOV.UK'
  end

  it 'will display title including driving licence number' do
    stub_cycle_three_attribute_request('drivingLicenseNumber')

    visit further_information_path

    expect(page).to have_title 'Enter your driving licence number - GOV.UK Verify - GOV.UK'
  end
end
