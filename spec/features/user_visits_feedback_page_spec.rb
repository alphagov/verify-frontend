require 'feature_helper'

RSpec.feature 'When the user visits the feedback page' do
  it 'should show errors for all input fields when missing input', js: true do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.error', count: 3)
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.reply'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.details'), count: 2)

    choose 'feedback_form_reply_true'
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to_not have_css('.error-message', text: I18n.t('hub.feedback.errors.reply'))
    expect(page).to have_css('.form-group.error', count: 4)
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.name'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.email'))
  end

  it 'should show errors for all input fields when missing input and user wants a reply' do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    choose 'feedback_form_reply_true'
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.error', count: 4)
    expect(page).to have_css('.validation-message', text: I18n.t('hub.feedback.errors.no_selection'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.name'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.email'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.details'), count: 2)
  end

  it 'should not show errors for name and email when missing input and user does not want a reply' do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    choose 'feedback_form_reply_false'
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.error', count: 2)
    expect(page).to have_css('.validation-message', text: I18n.t('hub.feedback.errors.no_selection'))
    expect(page).to_not have_css('.error-message', text: I18n.t('hub.feedback.errors.name'))
    expect(page).to_not have_css('.error-message', text: I18n.t('hub.feedback.errors.email'))
  end

  it 'should not show errors for reply when it is not selected' do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.error', count: 3)
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.reply'))
    expect(page).to have_css('.validation-message', text: I18n.t('hub.feedback.errors.no_selection'))
  end

  it 'should pass email not provided to feedback sent page when successful' do
    visit feedback_path

    fill_in 'feedback_form_what', with: 'Verify my identity'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_false'

    click_button I18n.t('hub.feedback.send_message')
    expect(current_url).to eql feedback_sent_url(emailProvided: false, sessionValid: false)
  end

  it 'should include email provided on feedback sent page when response requested' do
    visit feedback_path

    fill_in 'feedback_form_what', with: 'Verify my identity'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_true'
    fill_in 'feedback_form_name', with: 'Bob Smith'
    fill_in 'feedback_form_email', with: 'bob@smith.com'

    click_button I18n.t('hub.feedback.send_message')
    expect(current_url).to eql feedback_sent_url(emailProvided: true, sessionValid: false)
  end

  context 'with session' do
    it 'should pass email not provided to feedback sent page when successful' do
      set_session_cookies!
      visit feedback_path

      fill_in 'feedback_form_what', with: 'Verify my identity'
      fill_in 'feedback_form_details', with: 'Some details'
      choose 'feedback_form_reply_false'

      click_button I18n.t('hub.feedback.send_message')
      expect(current_url).to eql feedback_sent_url(emailProvided: false, sessionValid: true)
    end
  end

  it 'should not go to feedback sent page when a error with zendesk occurs' do
    visit feedback_path

    fill_in 'feedback_form_what', with: 'break_zendesk'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_false'
    fill_in 'feedback_form_name', with: 'Bob Smith'
    fill_in 'feedback_form_email', with: 'bob@smith.com'

    click_button I18n.t('hub.feedback.send_message')
    expect(page).to have_current_path(feedback_path)
    expect(page).to have_content(I18n.t('hub.feedback.errors.heading'))
    expect(page).to have_content(I18n.t('hub.feedback.errors.send_failure'))
  end

  it 'should contain referer, user_agent and js_disabled values on page' do
    visit feedback_path

    expect(page).to have_css('#feedback_form_js_disabled', visible: false)
  end

  it 'should set the referer and user agent' do
    user_agent = 'MY SUPER DUPER USER AGENT'
    page.driver.browser.header('User-Agent', user_agent)
    set_session_cookies!
    visit start_path
    click_on I18n.t('feedback_link')

    fill_in 'feedback_form_what', with: 'Verify my identity'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_false'

    click_button I18n.t('hub.feedback.send_message')

    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include 'From page: http://www.example.com/start'
    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include "User agent: #{user_agent}"
  end


  it 'should keep the referer if form submission fails validation' do
    set_session_cookies!
    visit start_path
    click_on I18n.t('feedback_link')

    fill_in 'feedback_form_what', with: 'Verify my identity'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_true'

    click_button I18n.t('hub.feedback.send_message')

    choose 'feedback_form_reply_false'

    click_button I18n.t('hub.feedback.send_message')

    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include 'From page: http://www.example.com/start'
  end
end
