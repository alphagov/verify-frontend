require 'feature_helper'

RSpec.feature 'When the user visits the feedback page' do
  before(:each) do
    set_session_cookies!
  end

  it 'should show errors for all input fields when missing input and user wants a reply' do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    choose 'feedback_form_reply_true'
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.error', count: 4)
    expect(page).to have_css '.validation-message', text: I18n.t('hub.feedback.errors.no_selection')
    expect(page).to have_css '.validation-message', text: I18n.t('hub.feedback.errors.name')
    expect(page).to have_css '.validation-message', text: I18n.t('hub.feedback.errors.email')
  end

  it 'should not show errors for name and email when missing input and user does not want a reply' do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    choose 'feedback_form_reply_false'
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.error', count: 2)
    expect(page).to have_css '.validation-message', text: I18n.t('hub.feedback.errors.no_selection')
    expect(page).to_not have_css '.validation-message', text: I18n.t('hub.feedback.errors.name')
    expect(page).to_not have_css '.validation-message', text: I18n.t('hub.feedback.errors.email')
  end

  it 'should go to feedback sent page when successful' do
    visit feedback_path

    fill_in 'feedback_form_what', with: 'Verify my identity'
    fill_in 'feedback_form_details', with: 'Some details'
    fill_in 'feedback_form_name', with: 'Bob Smith'
    fill_in 'feedback_form_email', with: 'bob@smith.com'

    click_button I18n.t('hub.feedback.send_message')
    expect(page).to have_current_path(feedback_sent_path)
  end
end
