require 'feature_helper'

RSpec.describe 'When the user visits the select phone page' do
  before(:each) do
    set_session_cookies!
  end

  context 'with javascript disabled' do
    it 'redirects to the will it work for me page when user has a phone' do
      stub_federation_no_docs
      visit '/select-phone'

      choose 'select_phone_form_mobile_phone_true'
      choose 'select_phone_form_smart_phone_true'
      choose 'select_phone_form_landline_true'
      click_button 'Continue'

      expect(page).to have_current_path(will_it_work_for_me_path, only_path: true)
    end
  end

  context 'with javascript enabled', js: true do
    it 'redirects to the will it work for me page when user has a phone' do
      stub_federation
      visit '/select-phone?selected-evidence=passport&selected-evidence=driving_licence'

      choose 'select_phone_form_mobile_phone_true'
      choose 'select_phone_form_smart_phone_true'
      click_button 'Continue'

      expect(page).to have_current_path(will_it_work_for_me_path, only_path: true)
      expect(query_params['selected-evidence'].to_set).to eql %w(mobile_phone smart_phone passport driving_licence).to_set
    end

    it 'should display a validation message when user does not answer mobile phone question' do
      stub_federation
      visit '/select-phone?selected-evidence=passport&selected-evidence=driving_licence'

      click_button 'Continue'

      expect(page).to have_current_path(select_phone_path, only_path: true)
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end

    it 'redirects to the no mobile phone page when no idps can verify' do
      stub_federation
      visit '/select-phone?selected-evidence=passport&selected-evidence=driving_licence&selected-evidence=non_uk_id_document'

      choose 'select_phone_form_mobile_phone_false'
      choose 'select_phone_form_landline_false'
      click_button 'Continue'

      expect(page).to have_current_path(no_mobile_phone_path, only_path: true)
      expect(query_params['selected-evidence'].to_set).to eql %w(passport driving_licence non_uk_id_document).to_set
    end
  end

  it 'includes the appropriate feedback source' do
    visit '/select-phone'

    expect_feedback_source_to_be(page, 'SELECT_PHONE_PAGE')
  end

  it 'displays the page in Welsh', pending: true do
    visit '/dethol-ffon'
    expect(page).to have_title 'A oes gennych ffôn symudol neu dabled? - GOV.UK Verify - GOV.UK'
    expect(page).to have_css 'html[lang=cy]'
  end

  context 'with javascript turned off', js: false do
    it 'shows an error message when no selections are made' do
      visit '/select-phone'
      click_button 'Continue'

      expect(page).to have_css '.validation-message', text: 'Please answer all the questions'
      expect(page).to have_css '.form-group.error'
    end
  end

  it 'reports to Piwik when form is valid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Phone Next' }

    stub_federation
    visit '/select-phone?selected-evidence=passport&selected-evidence=driving_licence'

    choose 'select_phone_form_mobile_phone_true'
    choose 'select_phone_form_smart_phone_true'
    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'does not report to Piwik when form is invalid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Phone Next' }
    visit '/select-phone?selected-evidence=passport&selected-evidence=driving_licence'

    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to_not have_been_made
  end
end
