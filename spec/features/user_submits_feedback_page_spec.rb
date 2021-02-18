require "feature_helper"
require "api_test_helper"

RSpec.feature "When the user submits the feedback page" do
  let(:what_text_field) { "Using verify" }
  let(:details_text_field) { "Some details" }
  let(:session_not_valid_link) {
    t("hub.feedback_sent.session_not_valid", link: t("hub.feedback_sent.session_not_valid_link"))
  }
  context "user session invalid" do
    before(:each) do
      stub_transactions_list
    end

    it "when user provides email should say message has been received and show invalid session link" do
      visit feedback_path

      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_true"
      fill_in "feedback_form_name", with: "Bob Smith"
      fill_in "feedback_form_email", with: "bob@smith.com"

      click_button t("hub.feedback.send_message")
      expect(page).to have_title t("hub.feedback_sent.heading")
      expect(page).to have_current_path(feedback_sent_path, ignore_query: true)
      expect(page).to have_content t("hub.feedback_sent.message_email")
      expect(page).to have_content session_not_valid_link
      expect(page).to have_content t("hub.transaction_list.heading")
    end

    it "when user does not provide email should not say message has been sent and show invalid session link" do
      visit feedback_path

      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_false"

      click_button t("hub.feedback.send_message")
      expect(page).to have_current_path(feedback_sent_path, ignore_query: true)
      expect(page).to_not have_content t("hub.feedback_sent.message_email")
      expect(page).to have_content session_not_valid_link
      expect(page).to have_content t("hub.transaction_list.heading")
    end

    it "when session has timed out should show invalid session link" do
      set_session_and_session_cookies!
      stub_api_idp_list_for_registration

      expired_start_time = (Integer(CONFIG.session_cookie_duration_mins) + 30).minutes.ago.to_i * 1000
      page.set_rack_session(start_time: expired_start_time)

      visit feedback_path

      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_false"

      click_button t("hub.feedback.send_message")
      expect(page).to have_content session_not_valid_link
      expect(page).to have_content t("hub.transaction_list.heading")
    end
  end

  it "should be able to direct user back to the Verify product page if email could not be sent on first attempt" do
    visit "/feedback?feedback-source=PRODUCT_PAGE"

    fill_in "feedback_form_what", with: what_text_field
    fill_in "feedback_form_details", with: details_text_field
    choose "feedback_form_reply_false", allow_label_click: true

    allow_any_instance_of(FeedbackService).to receive(:submit!).and_return(false)

    click_button t("hub.feedback.send_message")

    expect(page).to have_current_path(feedback_path)
    expect(page).to have_content what_text_field
    expect(page).to have_content details_text_field

    allow_any_instance_of(FeedbackService).to receive(:submit!).and_return(true)

    click_button t("hub.feedback.send_message")
    expect(page).to have_title t("hub.feedback_sent.heading")
    expect(page).to have_link t("hub.feedback_sent.product_page"), href: "https://govuk-verify.cloudapps.digital/"
  end

  context "user session valid" do
    before :each do
      set_session_and_session_cookies!
      stub_api_idp_list_for_registration
    end

    it "should show user link back to start page" do
      visit start_path
      navigate_to_feedback_form

      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_false"

      click_button t("hub.feedback.send_message")
      expect(page).to have_current_path(feedback_sent_path, ignore_query: true)
      expect(page).to_not have_content session_not_valid_link
      expect(page).to have_link t("hub.feedback_sent.session_valid_link"), href: start_path
    end

    it "should show user link back to page the user came from" do
      visit select_documents_path
      navigate_to_feedback_form
      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_false"

      click_button t("hub.feedback.send_message")
      expect(page).to have_current_path(feedback_sent_path, ignore_query: true)
      expect(page).to_not have_content session_not_valid_link
      expect(page).to have_link t("hub.feedback_sent.session_valid_link"), href: select_documents_path
    end

    it "should show user link back to start page if the user came from an error page" do
      visit about_path
      visit "/404"
      navigate_to_feedback_form
      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_false"

      click_button t("hub.feedback.send_message")
      expect(page).to have_current_path(feedback_sent_path, ignore_query: true)
      expect(page).to_not have_content session_not_valid_link
      expect(page).to have_link t("hub.feedback_sent.session_valid_link"), href: start_path
    end

    it "should show user link back to start page if the user directly visits the feedback page" do
      visit feedback_path

      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_false"

      click_button t("hub.feedback.send_message")
      expect(page).to have_current_path(feedback_sent_path, ignore_query: true)
      expect(page).to_not have_content session_not_valid_link
      expect(page).to have_link t("hub.feedback_sent.session_valid_link"), href: start_path
    end

    it "should show feedback sent in Welsh and have the appropriate link back to Verify" do
      visit select_documents_cy_path
      navigate_to_feedback_form :cy

      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_false"
      click_button t("hub.feedback.send_message", locale: :cy)

      expect(page).to have_title t("hub.feedback_sent.heading", locale: :cy)
      expect(page).to have_css "html[lang=cy]"
      expect(page).to have_link t("hub.feedback_sent.session_valid_link", locale: :cy), href: select_documents_cy_path
    end

    it "should be able to direct user back to the relevant page if user switches to Welsh on the feedback page" do
      visit "/feedback?feedback-source=START_PAGE"

      first(".available-languages").click_link("Cymraeg")

      expect(page).to have_current_path("/adborth")

      fill_in "feedback_form_what", with: what_text_field
      fill_in "feedback_form_details", with: details_text_field
      choose "feedback_form_reply_false", allow_label_click: true

      click_button t("hub.feedback.send_message", locale: :cy)
      expect(page).to have_link t("hub.feedback_sent.session_valid_link", locale: :cy), href: "/dechrau"
    end
  end
end
