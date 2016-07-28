require 'feature_helper'

RSpec.feature 'When the user submits the feedback page' do
  let(:session_not_valid_link) {
    I18n.t('hub.feedback_sent.session_not_valid', link: I18n.t('hub.feedback_sent.session_not_valid_link'))
  }

  it 'should tell the user that their message has been sent with email' do
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

  it 'should tell the user that their message has been sent without email' do
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

  it 'should tell the user that their message has been sent and link them back to the start page' do
    set_session_cookies!
    visit feedback_path

    fill_in 'feedback_form_what', with: 'Using verify'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_false'

    click_button I18n.t('hub.feedback.send_message')
    expect(page).to have_current_path(feedback_sent_path, only_path: true)
    expect(page).to_not have_content(I18n.t('hub.feedback_sent.message_email'))
    expect(page).to_not have_content(session_not_valid_link)
    expect(page).to have_link I18n.t('hub.feedback_sent.session_valid_link')
  end
end
