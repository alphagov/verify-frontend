require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the will it work for me page' do
  before(:each) do
    set_session_and_session_cookies!
  end

  it 'includes the appropriate feedback source' do
    visit '/will-it-work-for-me'
    expect_feedback_source_to_be(page, 'WILL_IT_WORK_FOR_ME_PAGE', '/will-it-work-for-me')
  end

  context 'shows a validation message when form is invalid' do
    it 'when js is off' do
      visit '/will-it-work-for-me'

      click_button 'Continue'

      expect(page).to have_current_path(will_it_work_for_me_path)
      expect(page).to have_content 'Please answer all the questions'
    end

    it 'when js is on', js: true do
      visit '/will-it-work-for-me'
      choose 'will_it_work_for_me_form_above_age_threshold_false', allow_label_click: true
      expect(page).to_not have_content(I18n.t('hub.will_it_work_for_me.question.not_resident_reason.title'))
      choose 'will_it_work_for_me_form_resident_last_12_months_false', allow_label_click: true
      expect(page).to have_content(I18n.t('hub.will_it_work_for_me.question.not_resident_reason.title'))
      click_button 'Continue'

      expect(page).to have_current_path(will_it_work_for_me_path)
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end
  end
end
