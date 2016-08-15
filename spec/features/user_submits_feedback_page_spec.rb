require 'feature_helper'

RSpec.feature 'When the user submits the feedback page' do
  let(:session_not_valid_link) {
    I18n.t('hub.feedback_sent.session_not_valid', link: I18n.t('hub.feedback_sent.session_not_valid_link'))
  }
  context 'user session invalid' do
    it 'when user provides email should say message has been received and show invalid session link' do
      visit feedback_path

      fill_in 'feedback_form_what', with: 'Using verify'
      fill_in 'feedback_form_details', with: 'Some details'
      choose 'feedback_form_reply_true'
      fill_in 'feedback_form_name', with: 'Bob Smith'
      fill_in 'feedback_form_email', with: 'bob@smith.com'

      click_button I18n.t('hub.feedback.send_message')
      expect(page).to have_title(I18n.t('hub.feedback_sent.title'))
      expect(page).to have_current_path(feedback_sent_path, only_path: true)
      expect(page).to have_content(I18n.t('hub.feedback_sent.message_email'))
      expect(page).to have_content(session_not_valid_link)
      expect(page).to have_link I18n.t('hub.feedback_sent.session_not_valid_link')
    end

    it 'when user does not provide email should not say message has been sent and show invalid session link' do
      visit feedback_path

      fill_in 'feedback_form_what', with: 'Using verify'
      fill_in 'feedback_form_details', with: 'Some details'
      choose 'feedback_form_reply_false'

      click_button I18n.t('hub.feedback.send_message')
      expect(page).to have_current_path(feedback_sent_path, only_path: true)
      expect(page).to_not have_content(I18n.t('hub.feedback_sent.message_email'))
      expect(page).to have_content(session_not_valid_link)
      expect(page).to have_link I18n.t('hub.feedback_sent.session_not_valid_link')
    end

    it 'when session has timed out should show invalid session link' do
      set_session_and_session_cookies!
      expired_start_time = 2.hours.ago.to_i * 1000
      page.set_rack_session(start_time: expired_start_time)

      visit feedback_path

      fill_in 'feedback_form_what', with: 'Using verify'
      fill_in 'feedback_form_details', with: 'Some details'
      choose 'feedback_form_reply_false'

      click_button I18n.t('hub.feedback.send_message')
      expect(page).to have_content(session_not_valid_link)
      expect(page).to have_link I18n.t('hub.feedback_sent.session_not_valid_link')
    end
  end

  context 'user session valid' do
    it 'should show user link back to start page' do
      set_session_and_session_cookies!
      visit feedback_path

      fill_in 'feedback_form_what', with: 'Using verify'
      fill_in 'feedback_form_details', with: 'Some details'
      choose 'feedback_form_reply_false'

      click_button I18n.t('hub.feedback.send_message')
      expect(page).to have_current_path(feedback_sent_path, only_path: true)
      expect(page).to_not have_content(session_not_valid_link)
      expect(page).to have_link I18n.t('hub.feedback_sent.session_valid_link')
    end

    it 'should show feedback sent in Welsh' do
      set_session_and_session_cookies!

      visit feedback_cy_path
      fill_in 'feedback_form_what', with: 'Using verify'
      fill_in 'feedback_form_details', with: 'Some details'
      choose 'feedback_form_reply_false'
      click_button I18n.t('hub.feedback.send_message', locale: :cy)

      expect(page).to have_title I18n.t('hub.feedback_sent.title', locale: :cy)
      expect(page).to have_css 'html[lang=cy]'
    end
  end
end
