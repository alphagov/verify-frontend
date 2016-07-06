require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'user visits further information page' do
  before(:each) do
    stub_federation
    page.set_rack_session(transaction_simple_id: 'test-rp')
    set_session_cookies!
  end

  it 'will display page for National Insurance number' do
    stub_cycle_three_attribute_request('NationalInsuranceNumber')

    visit further_information_path

    attribute_name = I18n.t('cycle3.NationalInsuranceNumber.name')
    rp_name = I18n.t('rps.test-rp.name').capitalize

    expect(page).to have_title I18n.t('hub.further_information.title', cycle_three_name: attribute_name)
    expect(page).to have_css 'h1.heading-xlarge', text: rp_name
    expect(page).to have_content I18n.t('hub.further_information.cycle_three_input_label', cycle_three_name: attribute_name)
    expect(page).to have_content I18n.t('cycle3.NationalInsuranceNumber.help_to_find')
    expect(page).to have_content I18n.t('hub.further_information.help_with_your', cycle_three_name: attribute_name)
    expect(page).to have_content I18n.t('hub.further_information.cancel', transaction_name: rp_name)
    expect_feedback_source_to_be(page, 'CYCLE_3_PAGE')
  end

  it 'will submit valid driving license number' do
    stub_cycle_three_attribute_request('DrivingLicenceNumber')
    stub_request = stub_cycle_three_value_submit('MORGA657054SM9IJ')

    stub_matching_outcome

    visit further_information_path

    fill_in 'cycle_three_form_cycle_three_data', with: 'MORGA657054SM9IJ'
    click_button I18n.t('navigation.continue')

    expect(page.current_path).to eql(response_processing_path)
    expect(stub_request).to have_been_made
  end
end
