require "feature_helper"
require "api_test_helper"

RSpec.feature "When user visits document selection page" do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
    page.set_rack_session(
      selected_answers: { documents: { driving_licence: false }, device_type: { device_type_other: true } },
    )
    visit "/select-documents"
  end

  it "includes the appropriate feedback source" do
    expect_feedback_source_to_be(page, "SELECT_DOCUMENTS_PAGE", "/select-documents")
  end

  it "should have a header about photo identity documents" do
    expect(page).to have_content t("hub.select_documents.heading")
  end

  it "should have a header about photo identity documents in Welsh if user selects Welsh" do
    visit "/dewis-dogfennau"
    expect(page).to have_content t("hub.select_documents.heading")
  end

  it "redirects to the idp picker page when selects 3 documents" do
    expect_reporter_to_receive(
      evidence: %i(has_valid_passport has_driving_license has_credit_card device_type_other),
      attempts: 1,
    )

    check t("hub.select_documents.has_driving_license"), allow_label_click: true
    check t("hub.select_documents.has_valid_passport"), allow_label_click: true
    check t("hub.select_documents.has_credit_card"), allow_label_click: true
    click_button t("navigation.continue")

    expect(page).to have_title t("hub.choose_a_certified_company.heading")
    expect(page).to have_current_path(choose_a_certified_company_path)
  end

  it "redirects to the idp picker page when user selects phone and passport documents" do
    check t("hub.select_documents.has_valid_passport"), allow_label_click: true
    check t("hub.select_documents.has_phone_can_app"), allow_label_click: true

    click_button t("navigation.continue")
    expect(page).to have_current_path(choose_a_certified_company_path)
  end

  it "redirects to the select advice page when selects 2 documents there not both (phone & passport)" do
    expect_reporter_to_receive(
      evidence: %i(has_driving_license has_credit_card device_type_other),
      attempts: 1,
    )

    check t("hub.select_documents.has_driving_license"), allow_label_click: true
    check t("hub.select_documents.has_credit_card"), allow_label_click: true
    click_button t("navigation.continue")

    expect(page).to have_title t("hub.select_documents_advice.advice_html.heading")
    expect(page).to have_current_path(select_documents_advice_path)
  end

  it "redirects to the select advice page when selects 2 documents and None of the above is checked" do
    expect_reporter_to_receive(
      evidence: %i(has_driving_license has_credit_card device_type_other),
      attempts: 1,
    )

    check t("hub.select_documents.has_driving_license"), allow_label_click: true
    check t("hub.select_documents.has_credit_card"), allow_label_click: true
    check t("hub.select_documents.has_nothing"), allow_label_click: true

    click_button t("navigation.continue")

    expect(page).to have_current_path(select_documents_advice_path)
  end

  it "increments attempts" do
    visit "/select-documents"
    expect_reporter_to_receive(
      evidence: %i(device_type_other),
      attempts: 1,
    )
    check t("hub.select_documents.has_nothing"), allow_label_click: true
    click_button t("navigation.continue")
    expect(page).to have_current_path(select_documents_advice_path)

    visit "/select-documents"
    expect_reporter_to_receive(
      evidence: %i(has_driving_license device_type_other),
      attempts: 2,
    )
    check t("hub.select_documents.has_driving_license"), allow_label_click: true
    click_button t("navigation.continue")
    expect(page).to have_current_path(select_documents_advice_path)

    visit "/select-documents"
    expect_reporter_to_receive(
      evidence: %i(has_driving_license has_credit_card device_type_other),
      attempts: 3,
    )
    check t("hub.select_documents.has_driving_license"), allow_label_click: true
    check t("hub.select_documents.has_credit_card"), allow_label_click: true
    click_button t("navigation.continue")
    expect(page).to have_current_path(select_documents_advice_path)

    visit "/select-documents"
    expect_reporter_to_receive(
      evidence: %i(has_valid_passport has_driving_license has_credit_card device_type_other),
      attempts: 4,
    )
    check t("hub.select_documents.has_driving_license"), allow_label_click: true
    check t("hub.select_documents.has_valid_passport"), allow_label_click: true
    check t("hub.select_documents.has_credit_card"), allow_label_click: true
    click_button t("navigation.continue")
    expect(page).to have_current_path(choose_a_certified_company_path)
  end

  def expect_reporter_to_receive(evidence:, attempts:)
    expect(FEDERATION_REPORTER).to receive(:report_user_evidence_attempt)
    .with(
      current_transaction: a_kind_of(Display::RpDisplayData),
      request: a_kind_of(ActionDispatch::Request),
      attempt_number: attempts,
      evidence_list: evidence,
    )
  end
end
