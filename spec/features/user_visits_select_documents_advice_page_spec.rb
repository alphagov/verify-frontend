require "feature_helper"
require "api_test_helper"
require "models/selected_answer_store"

RSpec.feature "user visits select documents advice pages", type: :feature do
  let(:document) {
    t("hub_variant_c.select_documents").select { |k, _| k.to_s.start_with?("has") }
  }
  before(:each) do
    experiment = { "short_hub_2019_q3-preview" => "short_hub_2019_q3-preview_variant_c_2_idp_short_hub" }
    set_session_and_ab_session_cookies!(experiment)
    stub_api_idp_list_for_registration
  end

  it "includes the appropriate feedback source" do
    visit select_documents_advice_path
    expect_feedback_source_to_be(page, "SELECT_DOCUMENTS_ADVICE_PAGE", "/select-documents-advice")
  end

  it "lists things you do not have with you when 'None of the above is checked'" do
    visit select_documents_path
    evidence_chosen(document[:has_nothing])
    click_button t("navigation.continue")

    expect(page).to have_current_path(select_documents_advice_path)
      .and have_content(t("hub_variant_c.select_documents_advice.advice_html.heading"))
      .and have_content(t("hub_variant_c.select_documents_advice.advice_html.sub_heading"))
      .and have_content(t("hub_variant_c.select_documents_advice.advice_html.unspecified"))
      .and have_content(t("hub_variant_c.select_documents_advice.what_to_do_next.heading"))

    expect_things_you_do_not_have_column_to_contain(
      document[:has_valid_passport], document[:has_driving_license], document[:has_phone_can_app], document[:has_credit_card]
    )
  end

  it "list things you have a credit card when it is checked and the other things you do not have" do
    visit select_documents_path
    evidence_chosen(document[:has_credit_card])
    click_button t("navigation.continue")

    expect(page).to have_current_path(select_documents_advice_path)
      .and have_content(t("hub_variant_c.select_documents_advice.advice_html.heading"))
      .and have_content(t("hub_variant_c.select_documents_advice.advice_html.sub_heading"))
      .and have_content(t("hub_variant_c.select_documents_advice.advice_html.unspecified"))
      .and have_content(t("hub_variant_c.select_documents_advice.advice_html.specified"))
      .and have_content(t("hub_variant_c.select_documents_advice.what_to_do_next.heading"))

    expect_things_you_have_column_to_contain(document[:has_credit_card])
    expect_things_you_do_not_have_column_to_contain(
      document[:has_valid_passport], document[:has_driving_license], document[:has_phone_can_app]
    )
  end

  it "navigates to select documents page" do
    visit select_documents_advice_path
    click_link t("hub_variant_c.select_documents_advice.what_to_do_next.change_your_answers_link", select_documents_path)
    expect(page).to have_current_path(select_documents_path)
  end

  it "navigates to prove your identity another way page" do
    visit select_documents_advice_path
    click_link t("hub_variant_c.select_documents_advice.what_to_do_next.prove_your_identity_link", prove_your_identity_another_way_path)
    expect(page).to have_current_path(prove_your_identity_another_way_path)
  end

  def evidence_chosen(*values)
    values.each { |value| check value, allow_label_click: true }
  end

  def expect_things_you_have_column_to_contain(*values)
    within('//*[@id="#evidence_specified"]') do
      values.each { |value| expect(page).to have_content value }
    end
  end

  def expect_things_you_do_not_have_column_to_contain(*values)
    within('//*[@id="#evidence_unspecified"]') do
      values.each { |value| expect(page).to have_content value }
    end
  end
end
