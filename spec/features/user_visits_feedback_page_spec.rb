require 'feature_helper'

RSpec.feature 'When the user visits the feedback page' do
  let(:long_text_limit) { FeedbackForm::LONG_TEXT_LIMIT }

  it 'should link back to the product page when user came from the product page' do
    visit '/feedback?feedback-source=PRODUCT_PAGE'

    fill_in 'feedback_form_what', with: 'Verify my identity'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_false', allow_label_click: true

    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_title(I18n.t('hub.feedback_sent.title'))

    expect(page).to have_link 'Return to the GOV.UK Verify product page', href: 'https://govuk-verify.cloudapps.digital/'
  end

  it 'should show errors for all input fields when missing input', js: true do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.form-group-error', count: 3)
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.reply'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.details'), count: 2)

    choose 'feedback_form_reply_true', allow_label_click: true
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to_not have_css('.error-message', text: I18n.t('hub.feedback.errors.reply'))
    expect(page).to have_css('.form-group.form-group-error', count: 4)
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.name'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.email'))
  end

  it 'should show errors for email address when not valid', js: true do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    choose 'feedback_form_reply_true', allow_label_click: true
    fill_in 'feedback_form_email', with: 'foo@bar'
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.email'))

    fill_in 'feedback_form_email', with: 'foo@bar.com'
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to_not have_css('.error-message', text: I18n.t('hub.feedback.errors.email'))
  end

  it 'should show errors for all input fields when missing input and user wants a reply' do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    choose 'feedback_form_reply_true', allow_label_click: true
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.form-group-error', count: 4)
    expect(page).to have_css('.validation-message', text: I18n.t('hub.feedback.errors.no_selection'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.name'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.email'))
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.details'), count: 2)
  end

  it 'should show errors when input fields values too long' do
    visit feedback_path

    fill_in 'feedback_form_what', with: 'A' * (long_text_limit + 1)
    fill_in 'feedback_form_details', with: 'A' * (long_text_limit + 1)
    choose 'feedback_form_reply_false', allow_label_click: true

    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.form-group-error', count: 2)
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.too_long', max_length: long_text_limit), count: 2)
  end

  it 'should not show errors for name and email when missing input and user does not want a reply' do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    choose 'feedback_form_reply_false', allow_label_click: true
    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.form-group-error', count: 2)
    expect(page).to have_css('.validation-message', text: I18n.t('hub.feedback.errors.no_selection'))
    expect(page).to_not have_css('.error-message', text: I18n.t('hub.feedback.errors.name'))
    expect(page).to_not have_css('.error-message', text: I18n.t('hub.feedback.errors.email'))
  end

  it 'should not show errors for reply when it is not selected' do
    visit feedback_path
    expect(page).to have_title(I18n.t('hub.feedback.title'))

    click_button I18n.t('hub.feedback.send_message')

    expect(page).to have_css('.form-group.form-group-error', count: 3)
    expect(page).to have_css('.error-message', text: I18n.t('hub.feedback.errors.reply'))
    expect(page).to have_css('.validation-message', text: I18n.t('hub.feedback.errors.no_selection'))
  end

  it 'should report on the what box character limit', js: true do
    visit feedback_path

    what = 'verify my identity'
    character_count_message_suffix = I18n.t('hub.feedback.character_count_message', limit_message: I18n.t('hub.feedback.character_limit_message'))
    expect(page).to have_content(I18n.t('hub.feedback.character_limit_message'))
    expect(page).to_not have_content(character_count_message_suffix)
    fill_in 'feedback_form_what', with: what
    page.execute_script('$("#feedback_form_what").triggerHandler("txtinput")')
    expect(page).to have_content("#{long_text_limit - what.size}#{character_count_message_suffix}")
  end

  it 'should report on the details box character limit', js: true do
    visit feedback_path

    details = 'here are some details'

    character_count_message_suffix = I18n.t('hub.feedback.character_count_message', limit_message: I18n.t('hub.feedback.character_limit_message'))
    expect(page).to have_content(I18n.t('hub.feedback.character_limit_message'))
    expect(page).to_not have_content(character_count_message_suffix)
    fill_in 'feedback_form_details', with: details
    page.execute_script('$("#feedback_form_details").triggerHandler("txtinput")')
    expect(page).to have_content("#{long_text_limit - details.size}#{character_count_message_suffix}")
  end

  it 'should not go to feedback sent page when a error with zendesk occurs' do
    visit feedback_path

    fill_in 'feedback_form_what', with: 'break_zendesk'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_false', allow_label_click: true
    fill_in 'feedback_form_name', with: 'Bob Smith'
    fill_in 'feedback_form_email', with: 'bob@smith.com'

    click_button I18n.t('hub.feedback.send_message')
    expect(page).to have_current_path(feedback_path)
    expect(page).to have_content(I18n.t('hub.feedback.errors.heading'))
    expect(page).to have_content(I18n.t('hub.feedback.errors.send_failure'))
  end

  it 'should contain js_disabled value on page' do
    visit feedback_path

    expect(page).to have_css('#feedback_form_js_disabled', visible: false)
  end

  it 'should set the referer and user agent' do
    user_agent = 'MY SUPER DUPER USER AGENT'
    page.driver.browser.header('User-Agent', user_agent)
    set_session_and_session_cookies!
    visit start_path
    click_on I18n.t('feedback_link.feedback_form')

    fill_in 'feedback_form_what', with: 'Verify my identity'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_false', allow_label_click: true

    click_button I18n.t('hub.feedback.send_message')

    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include 'From page: http://www.example.com/start'
    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include "User agent: #{user_agent}"
  end


  it 'should keep the referer if form submission fails validation' do
    set_session_and_session_cookies!
    visit start_path
    click_on I18n.t('feedback_link.feedback_form')

    fill_in 'feedback_form_what', with: 'Verify my identity'
    fill_in 'feedback_form_details', with: 'Some details'
    choose 'feedback_form_reply_true', allow_label_click: true

    click_button I18n.t('hub.feedback.send_message')

    choose 'feedback_form_reply_false', allow_label_click: true

    click_button I18n.t('hub.feedback.send_message')

    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include 'From page: http://www.example.com/start'
  end

  it 'should also be in welsh' do
    visit feedback_cy_path
    expect(page).to have_title I18n.t('hub.feedback.title', locale: :cy)
    expect(page).to have_css 'html[lang=cy]'
  end
end
