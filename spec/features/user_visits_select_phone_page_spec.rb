require 'feature_helper'

RSpec.describe 'When the user visits the select phone page' do
  before(:each) do
    set_session_cookies!
  end

  context 'with javascript disabled', driver: :no_js_selenium do
    it 'redirects to the will it work for me page when user has a phone' do
      stub_federation
      visit '/select-phone?selected-evidence=driving_licence'

      choose 'select_phone_form_mobile_phone_true'
      choose 'select_phone_form_smart_phone_true'
      choose 'select_phone_form_landline_true'
      click_button 'Continue'

      expect(page).to have_current_path(will_it_work_for_me_path, only_path: true)
    end

    it 'redirects to the no mobile phone page when no idps can verify' do
      stub_federation
      visit '/select-phone?selected-evidence=passport&selected-evidence=driving_licence'

      choose 'select_phone_form_mobile_phone_false'
      choose 'select_phone_form_landline_false'
      click_button 'Continue'

      expect(page).to have_current_path(no_mobile_phone_path, only_path: true)
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

      expect(page).to have_css '.validation-message', text: 'Please answer the question'
      expect(page).to have_css '.form-group.error'
    end
  end
end
