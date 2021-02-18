require "feature_helper"

RSpec.feature "When the user visits the feedback page" do
  let(:what_text_field) { "Using verify" }
  let(:details_text_field) { "Some details" }
  let(:long_text_limit) { FeedbackForm::LONG_TEXT_LIMIT }

  it "should link back to the product page when user came from the product page" do
    visit "/feedback?feedback-source=PRODUCT_PAGE"

    fill_in "feedback_form_what", with: what_text_field
    fill_in "feedback_form_details", with: details_text_field
    choose "feedback_form_reply_false", allow_label_click: true

    click_button t("hub.feedback.send_message")

    expect(page).to have_title t("hub.feedback_sent.heading")

    expect(page).to have_link t("hub.feedback_sent.product_page"), href: "https://govuk-verify.cloudapps.digital/"
  end

  it "should display and something went wrong if the feedback source is not valid" do
    visit "/feedback?feedback-source=something_not_valid"

    expect(page).to have_content t("errors.page_not_found.heading")
  end

  it "should show errors for all input fields when missing input", js: true do
    visit feedback_path
    expect(page).to have_title t("hub.feedback.heading")

    click_button t("hub.feedback.send_message")

    expect(page).to have_css(".govuk-form-group.govuk-form-group--error", count: 3)
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.reply"))
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.details"), count: 2)

    choose "feedback_form_reply_true", allow_label_click: true
    click_button t("hub.feedback.send_message")

    expect(page).to_not have_css(".govuk-error-message", text: t("hub.feedback.errors.reply"))
    expect(page).to have_css(".govuk-form-group.govuk-form-group--error", count: 4)
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.name"))
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.email"))
  end

  it "should show errors for email address when not valid", js: true do
    visit feedback_path
    expect(page).to have_title t("hub.feedback.heading")

    choose "feedback_form_reply_true", allow_label_click: true
    fill_in "feedback_form_email", with: "foo@bar"
    click_button t("hub.feedback.send_message")

    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.email"))

    fill_in "feedback_form_email", with: "foo@bar.com"
    click_button t("hub.feedback.send_message")

    expect(page).to_not have_css(".govuk-error-message", text: t("hub.feedback.errors.email"))
  end

  it "should show errors for all input fields when missing input and user wants a reply" do
    visit feedback_path
    expect(page).to have_title t("hub.feedback.heading")

    choose "feedback_form_reply_true", allow_label_click: true
    click_button t("hub.feedback.send_message")

    expect(page).to have_css(".govuk-form-group.govuk-form-group--error", count: 4)
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.name"))
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.email"))
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.what"))
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.details"))
  end

  it "should show errors when input fields values too long" do
    visit feedback_path

    fill_in "feedback_form_what", with: "A" * (long_text_limit + 1)
    fill_in "feedback_form_details", with: "A" * (long_text_limit + 1)
    choose "feedback_form_reply_false", allow_label_click: true

    click_button t("hub.feedback.send_message")

    expect(page).to have_css(".govuk-form-group.govuk-form-group--error", count: 2)
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.too_long", max_length: long_text_limit), count: 2)
  end

  it "should not show errors for name and email when missing input and user does not want a reply" do
    visit feedback_path
    expect(page).to have_title t("hub.feedback.heading")

    choose "feedback_form_reply_false", allow_label_click: true
    click_button t("hub.feedback.send_message")

    expect(page).to have_css(".govuk-form-group.govuk-form-group--error", count: 2)
    expect(page).to_not have_css(".govuk-error-message", text: t("hub.feedback.errors.name"))
    expect(page).to_not have_css(".govuk-error-message", text: t("hub.feedback.errors.email"))
  end

  it "should not show errors for reply when it is not selected" do
    visit feedback_path
    expect(page).to have_title t("hub.feedback.heading")

    click_button t("hub.feedback.send_message")

    expect(page).to have_css(".govuk-form-group.govuk-form-group--error", count: 3)
    expect(page).to have_css(".govuk-error-message", text: t("hub.feedback.errors.reply"))
  end

  it "should report on the what box character limit", js: true do
    visit feedback_path

    character_count_message_suffix = t("hub.feedback.character_count_message", limit_message: t("hub.feedback.character_limit_message"))
    expect(page).to have_content "You have 3000 characters remaining"
    expect(page).to_not have_content character_count_message_suffix
    fill_in "feedback_form_what", with: what_text_field
    page.execute_script('$("#feedback_form_what").triggerHandler("txtinput")')
    expect(page).to have_content("#{long_text_limit - what_text_field.size} characters remaining")
  end

  it "should report on the details box character limit", js: true do
    visit feedback_path

    character_count_message_suffix = t("hub.feedback.character_count_message", limit_message: t("hub.feedback.character_limit_message"))
    expect(page).to have_content "You have 3000 characters remaining"
    expect(page).to_not have_content character_count_message_suffix
    fill_in "feedback_form_details", with: details_text_field
    page.execute_script('$("#feedback_form_details").triggerHandler("txtinput")')
    expect(page).to have_content("#{long_text_limit - details_text_field.size} characters remaining")
  end

  it "should not go to feedback sent page when a error with zendesk occurs" do
    visit feedback_path

    fill_in "feedback_form_what", with: "break_zendesk"
    fill_in "feedback_form_details", with: details_text_field
    choose "feedback_form_reply_false", allow_label_click: true
    fill_in "feedback_form_name", with: "Bob Smith"
    fill_in "feedback_form_email", with: "bob@smith.com"

    click_button t("hub.feedback.send_message")
    expect(page).to have_current_path(feedback_path)
    expect(page).to have_content t("hub.feedback.errors.heading")
    expect(page).to have_content t("hub.feedback.errors.send_failure")
  end

  it "should contain js_disabled value on page" do
    visit feedback_path

    expect(page).to have_css("#feedback_form_js_disabled", visible: false)
  end

  it "should set the referer and user agent" do
    user_agent = "MY SUPER DUPER USER AGENT"
    page.driver.browser.header("User-Agent", user_agent)
    set_session_and_session_cookies!
    visit start_path
    navigate_to_feedback_form

    fill_in "feedback_form_what", with: what_text_field
    fill_in "feedback_form_details", with: details_text_field
    choose "feedback_form_reply_false", allow_label_click: true

    click_button t("hub.feedback.send_message")

    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include "From page: http://www.example.com/start"
    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include "User agent: #{user_agent}"
  end

  it "should keep the referer if form submission fails validation" do
    set_session_and_session_cookies!
    visit start_path
    navigate_to_feedback_form

    fill_in "feedback_form_what", with: what_text_field
    fill_in "feedback_form_details", with: details_text_field
    choose "feedback_form_reply_true", allow_label_click: true

    click_button t("hub.feedback.send_message")

    choose "feedback_form_reply_false", allow_label_click: true

    click_button t("hub.feedback.send_message")

    expect(DUMMY_ZENDESK_CLIENT.tickets.last.comment).to include "From page: http://www.example.com/start"
  end

  it "should show altered feedback form when feedback disabled" do
    set_session_and_session_cookies!
    stub_const("FEEDBACK_DISABLED", true)
    visit start_path
    navigate_to_feedback_form

    expect(page).to have_content "Feedback is disabled on this environment"
  end

  it "should also be in welsh" do
    visit feedback_cy_path
    expect(page).to have_title t("hub.feedback.heading", locale: :cy)
    expect(page).to have_css "html[lang=cy]"
  end
end
