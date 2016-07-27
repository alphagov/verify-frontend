require 'feature_helper'

RSpec.feature 'When the user submits the feedback page' do
  it 'should tell the user that their message has been sent with email' do
    visit feedback_path

    fill_in 'feedback_form_what', with: 'Using verify'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_true'
    fill_in 'feedback_form_name', with: 'Bob Smith'
    fill_in 'feedback_form_email', with: 'bob@smith.com'

    click_button I18n.t('hub.feedback.send_message')
    expect(page).to have_current_path(feedback_sent_path, only_path: true)
    expect(page).to have_content(I18n.t('hub.feedback_sent.message_email'))
    expect(page).to_not have_content(I18n.t('hub.feedback_sent.message_no_email'))
    expect(page).to have_content(I18n.t('hub.feedback_sent.session_timeout'))
  end

  it 'should tell the user that their message has been sent without email' do
    visit feedback_path

    fill_in 'feedback_form_what', with: 'Using verify'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_false'


    click_button I18n.t('hub.feedback.send_message')
    expect(page).to have_current_path(feedback_sent_path, only_path: true)
    expect(page).to_not have_content(I18n.t('hub.feedback_sent.message_email'))
    expect(page).to have_content(I18n.t('hub.feedback_sent.message_no_email'))
    expect(page).to have_content(I18n.t('hub.feedback_sent.session_timeout'))
  end
end
