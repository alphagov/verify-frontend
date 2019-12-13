require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'user visits further information page' do
  before(:each) do
    set_session_and_session_cookies!
    set_selected_idp_in_session(entity_id: "http://idcorp.com", simple_id: 'stub-idp-one')
  end
  let(:attribute_field_name) { t('cycle3.NationalInsuranceNumber.field_name') }
  let(:attribute_name) { t('cycle3.NationalInsuranceNumber.name') }


  it 'should also be in welsh' do
    stub_cycle_three_attribute_request('NationalInsuranceNumber')
    visit further_information_cy_path
    expect(page).to have_title t('hub.further_information.title', cycle_three_name: attribute_field_name, locale: :cy)
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'will display page for National Insurance number' do
    stub_cycle_three_attribute_request('NationalInsuranceNumber')

    visit further_information_path

    rp_name = t('rps.test-rp.name')

    expect(page).to have_title t('hub.further_information.title', cycle_three_name: attribute_field_name)
    expect(page).to have_css '.form-label-bold', text: attribute_field_name
    expect(page).to have_css 'span.form-hint', text: t('hub.further_information.example_text', example: t('cycle3.NationalInsuranceNumber.example'))
    expect(page).to have_content t('hub.further_information.first_time')
    expect(page).to have_content t('hub.further_information.help_with_your', cycle_three_name: attribute_name)
    expect(page).to have_content 'Your National Insurance number can be found on'
    expect(page).to have_content t('hub.further_information.cancel', transaction_name: rp_name)
    expect_feedback_source_to_be(page, 'CYCLE_3_PAGE', further_information_path)
  end

  it 'allows the introductory text to be customised' do
    stub_cycle_three_attribute_request('DrivingLicenceNumber')
    visit further_information_path

    expect(page.body).to include t('cycle3.DrivingLicenceNumber.intro_html')
    expect(page).not_to have_content t('hub.further_information.first_time')
  end

  it 'will submit valid driving license number' do
    piwik_request = stub_piwik_cycle_three('DrivingLicenceNumber')
    stub_cycle_three_attribute_request('DrivingLicenceNumber')
    stub_request = stub_cycle_three_value_submit('MORGA657054SM9IJ')

    stub_matching_outcome

    visit further_information_path

    fill_in 'cycle_three_attribute_cycle_three_data', with: 'MORGA657054SM9IJ 20'
    click_button t('navigation.continue')

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

    rp_name = t('rps.test-rp.name')
    click_button t('hub.further_information.cancel', transaction_name: rp_name)

    expect(page.current_path).to eql(redirect_to_service_start_again_path)
    expect(piwik_request).to have_been_made
    expect(cancel_request).to have_been_made
  end

  it 'will submit empty cycle 3 attribute when user clicks the no attribute link', js: true do
    piwik_request = stub_piwik_cycle_three('NullableAttribute')
    stub_cycle_three_attribute_request('NullableAttribute')
    stub_request = stub_cycle_three_value_submit('')
    stub_matching_outcome

    visit further_information_path
    click_button t('hub.further_information.null_attribute',
                        cycle_three_name: t('cycle3.NullableAttribute.name'))

    expect(page.current_path).to eql(response_processing_path)
    expect(stub_request).to have_been_made
    expect(piwik_request).to have_been_made
  end

  it 'will error if user tries to submit to null attribute end point with non-nullable attribute' do
    # This test is simulating a situation where someone will craft a submit to the null attribute submit endpoint during
    # a journey with an rp that does not allow nullable cycle 3 attributes.
    # We are doing this by hacking the response from  the api to return different cycle 3 attributes on loading the page
    # so that we generate a link for capybara and submitting where nullable is not allowed.
    matching_attribute_request = stub_cycle_three_attribute_request('NullableAttribute')
      .to_return(body: { name: 'DrivingLicenceNumber' }.to_json)
    stub_transactions_list

    visit further_information_path

    click_button t('hub.further_information.null_attribute',
                        cycle_three_name: t('cycle3.NullableAttribute.name'))
    expect(page).to have_content t('errors.something_went_wrong.heading')
    expect(matching_attribute_request).to have_been_made.twice
  end

  context 'with js off' do
    it 'will reject an invalid national insurance number' do
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      stub_matching_outcome

      visit further_information_path

      invalid_input = 'not valid'
      fill_in 'cycle_three_attribute_cycle_three_data', with: invalid_input
      click_button t('navigation.continue')

      expect(page.current_path).to eql(further_information_path)
      expect(page).to have_css(
        '.error-message',
        text: t('hub.further_information.attribute_validation_message', cycle_three_name: attribute_name)
      )
      expect(page.find('#cycle_three_attribute_cycle_three_data').value).to eql invalid_input
    end
  end

  context 'with js on', js: true do
    it 'will reject an invalid national insurance number' do
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      stub_matching_outcome

      visit further_information_path

      expect(page).not_to have_css '.error-message', text: t('hub.further_information.attribute_validation_message', cycle_three_name: attribute_name)

      invalid_input = 'not valid'
      fill_in 'cycle_three_attribute_cycle_three_data', with: invalid_input

      click_button t('navigation.continue')

      expect(page).to have_current_path(further_information_path)
      expect(page).to have_css '.govuk-error-message', text: t('hub.further_information.attribute_validation_message', cycle_three_name: attribute_name)
      expect(page.find('#cycle_three_attribute_cycle_three_data').value).to eql invalid_input
    end
  end

  context 'timeout modal', js: true do
    it 'will not show up if the expiry time is >5mins' do
      page.set_rack_session(assertion_expiry: 10.minutes.from_now)
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      visit further_information_path

      expect(page).to have_current_path(further_information_path)
      expect(page).to have_selector('#js-modal-dialog', visible: false)
    end

    it 'will show up if the expiry time is <5mins' do
      page.set_rack_session(assertion_expiry: 4.minutes.from_now)
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      visit further_information_path

      expect(page).to have_current_path(further_information_path)
      expect(page).to have_selector('#js-modal-dialog', visible: true)
    end

    it 'can be closed when shown' do
      page.set_rack_session(assertion_expiry: 4.minutes.from_now)
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      visit further_information_path

      expect(page).to have_current_path(further_information_path)
      expect(page).to have_selector('#js-modal-dialog', visible: true)

      find(".js-dialog-close").click
      expect(page).to have_selector('#js-modal-dialog', visible: false)
    end

    it 'can be closed and signed out when shown' do
      page.set_rack_session(assertion_expiry: 4.minutes.from_now)
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      visit further_information_path

      expect(page).to have_current_path(further_information_path)
      expect(page).to have_selector('#js-modal-dialog', visible: true)
      click_link t('hub.further_information.modal.button_signout')
      expect(page).to have_current_path(further_information_timeout_path)
    end

    it 'will show up automatically if the timeout limit reaches 5 mins' do
      page.set_rack_session(assertion_expiry: 303.seconds.from_now)
      stub_cycle_three_attribute_request('NationalInsuranceNumber')

      visit further_information_path

      expect(page).to have_selector('#js-modal-dialog', visible: false)
      sleep 6
      expect(page).to have_selector('#js-modal-dialog', visible: true)
      expect(page).to have_current_path(further_information_path)
    end
  end
end
