require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'user visits further information page' do
  before(:each) do
    stub_federation
    page.set_rack_session(transaction_simple_id: 'test-rp')
    set_session_cookies!
  end
  attribute_field_name = I18n.t('cycle3.NationalInsuranceNumber.field_name')
  attribute_name = I18n.t('cycle3.NationalInsuranceNumber.name')


  it 'should also be in welsh' do
    stub_cycle_three_attribute_request('NationalInsuranceNumber')
    visit further_information_cy_path
    expect(page).to have_title I18n.t('hub.further_information.title', cycle_three_name: attribute_field_name, locale: :cy)
    pending 'welsh routes are not localised yet'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'will display page for National Insurance number' do
    stub_cycle_three_attribute_request('NationalInsuranceNumber')

    visit further_information_path

    rp_name = I18n.t('rps.test-rp.name').capitalize

    expect(page).to have_title I18n.t('hub.further_information.title', cycle_three_name: attribute_field_name)
    expect(page).to have_css 'h1.heading-xlarge', text: rp_name
    expect(page).to have_css '.form-label-bold', text: attribute_field_name
    expect(page).to have_css 'span.form-hint', text: I18n.t('hub.further_information.example_text', example: I18n.t('cycle3.NationalInsuranceNumber.example'))
    expect(page).to have_content I18n.t('hub.further_information.help_with_your', cycle_three_name: attribute_name)
    expect(page).to have_content 'Your National Insurance number can be found on'
    expect(page).to have_content I18n.t('hub.further_information.cancel', transaction_name: rp_name)
    expect_feedback_source_to_be(page, 'CYCLE_3_PAGE')
  end

  it 'will submit valid driving license number' do
    piwik_request = stub_piwik_cycle_three('DrivingLicenceNumber')
    stub_cycle_three_attribute_request('DrivingLicenceNumber')
    stub_request = stub_cycle_three_value_submit('MORGA657054SM9IJ')

    stub_matching_outcome

    visit further_information_path

    fill_in 'cycle_three_form_cycle_three_data', with: 'MORGA657054SM9IJ 20'
    click_button I18n.t('navigation.continue')

    expect(page.current_path).to eql(response_processing_path)
    expect(stub_request).to have_been_made
    expect(piwik_request).to have_been_made
  end

  it 'will redirect to start on cancel' do
    piwik_request = stub_piwik_cycle_three_cancel
    cancel_request = stub_cycle_three_cancel
    stub_cycle_three_attribute_request('DrivingLicenceNumber')
    stub_response_for_rp

    visit further_information_path

    rp_name = I18n.t('rps.test-rp.name').capitalize
    click_button I18n.t('hub.further_information.cancel', transaction_name: rp_name)

    expect(page.current_path).to eql(redirect_to_service_start_again_path)
    expect(piwik_request).to have_been_made
    expect(cancel_request).to have_been_made
  end

  nullable_attribute_name = I18n.t('cycle3.NullableAttribute.name')

  it 'will allow the user to select no value for configured matching attributes' do
    piwik_request = stub_piwik_cycle_three('NullableAttribute')
    stub_cycle_three_attribute_request('NullableAttribute')
    stub_request = stub_cycle_three_value_submit('')
    stub_matching_outcome

    visit further_information_path
    check I18n.t(
      'hub.further_information.null_attribute',
      cycle_three_name: nullable_attribute_name
    )
    click_button I18n.t('navigation.continue')

    expect(page.current_path).to eql(response_processing_path)
    expect(stub_request).to have_been_made
    expect(piwik_request).to have_been_made
  end

  context 'with js off' do
    it 'will reject an invalid national insurance number' do
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      stub_matching_outcome

      visit further_information_path

      invalid_input = 'not valid'
      fill_in 'cycle_three_form_cycle_three_data', with: invalid_input
      click_button I18n.t('navigation.continue')

      expect(page.current_path).to eql(further_information_path)
      expect(page).to have_css(
        '.error-message',
        text: I18n.t('hub.further_information.attribute_validation_message', cycle_three_name: attribute_name)
      )
      expect(page.find('#cycle_three_form_cycle_three_data').value).to eql invalid_input
    end
  end

  context 'with js on', js: true do
    it 'will reject an invalid national insurance number' do
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      stub_matching_outcome

      visit further_information_path

      invalid_input = 'not valid'
      fill_in 'cycle_three_form_cycle_three_data', with: invalid_input

      click_button I18n.t('navigation.continue')

      expect(page).to have_current_path(further_information_path)
      expect(page).to have_css '.error-message', text: I18n.t('hub.further_information.attribute_validation_message', cycle_three_name: attribute_name)
      expect(page.find('#cycle_three_form_cycle_three_data').value).to eql invalid_input
    end

    it 'will allow the user to select no value for configured matching attributes' do
      piwik_request = stub_piwik_cycle_three('NullableAttribute')
      stub_cycle_three_attribute_request('NullableAttribute')
      stub_request = stub_cycle_three_value_submit('')
      stub_matching_outcome

      visit further_information_path
      click_button I18n.t('navigation.continue')
      expect(page).to have_css '.error-message', text: I18n.t('hub.further_information.attribute_validation_message', cycle_three_name: nullable_attribute_name)
      check I18n.t('hub.further_information.null_attribute', cycle_three_name: nullable_attribute_name)
      click_button I18n.t('navigation.continue')

      expect(page.current_path).to eql(response_processing_path)
      expect(stub_request).to have_been_made
      expect(piwik_request).to have_been_made
    end
  end
end
