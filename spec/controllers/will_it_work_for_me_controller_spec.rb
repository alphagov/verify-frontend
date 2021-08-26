require "rails_helper"
require "controller_helper"
require "will_it_work_for_me_examples"
require "piwik_test_helper"

describe WillItWorkForMeController do
  proceed_to_about_document_answers = { above_age_threshold: "true", resident_last_12_months: "true" }.freeze
  not_old_enough_answers = { above_age_threshold: "false", resident_last_12_months: "true" }.freeze
  not_old_enough_and_no_address_answers = { above_age_threshold: "false", resident_last_12_months: "false", not_resident_reason: "NoAddress" }.freeze
  not_old_enough_and_not_resident_answers = { above_age_threshold: "false", resident_last_12_months: "false", not_resident_reason: "AddressButNotResident" }.freeze
  not_old_enough_and_not_resident_moved_recently_answers = { above_age_threshold: "false", resident_last_12_months: "false", not_resident_reason: "MovedRecently" }.freeze
  moved_to_uk_last_year_answers = { above_age_threshold: "true", resident_last_12_months: "false", not_resident_reason: "MovedRecently" }.freeze
  non_resident_answers = { above_age_threshold: "true", resident_last_12_months: "false", not_resident_reason: "AddressButNotResident" }.freeze
  no_uk_address_answers = { above_age_threshold: "true", resident_last_12_months: "false", not_resident_reason: "NoAddress" }.freeze
  invalid_form_answers = { above_age_threshold: "true" }.freeze

  context "valid form" do
    include_examples "will_it_work_for_me",
                     "redirects to might not work for you if moved in recently",
                     "user has moved to the UK in the last year",
                     moved_to_uk_last_year_answers,
                     :why_might_this_not_work_for_me_path

    include_examples "will_it_work_for_me",
                     "redirects to might not work for you if underage",
                     "user is less than 20 yrs old",
                     not_old_enough_answers,
                     :why_might_this_not_work_for_me_path

    include_examples "will_it_work_for_me",
                     "redirects to will not work without a UK address page",
                     "user is less than 20 years old and does not have a UK address",
                     not_old_enough_and_no_address_answers,
                     :will_not_work_without_uk_address_path

    include_examples "will_it_work_for_me",
                     "redirects to overseas page if user has UK address but does not live in the UK",
                     "user is less than 20 years old, has a UK Address, but does not live in the UK",
                     not_old_enough_and_not_resident_answers,
                     :may_not_work_if_you_live_overseas_path

    include_examples "will_it_work_for_me",
                     "redirects to overseas page if user has UK address but does not live in the UK",
                     "user is less than 20 years old, has a UK Address, but does not live in the UK",
                     not_old_enough_and_not_resident_moved_recently_answers,
                     :why_might_this_not_work_for_me_path

    include_examples "will_it_work_for_me",
                     "redirects to the will not work page if user has no UK address",
                     "user is over 20 years old, but does not have a UK address",
                     no_uk_address_answers,
                     :will_not_work_without_uk_address_path

    include_examples "will_it_work_for_me",
                     "redirects to overseas page if user has UK address but does not live in the UK",
                     "user is over 20 years old, has a UK address, but does not live in the UK",
                     non_resident_answers,
                     :may_not_work_if_you_live_overseas_path

    include_examples "will_it_work_for_me",
                     "redirects to about documents path if user is over 20 and lives in the UK",
                     "user is over 20 years old, and lives in the UK",
                     proceed_to_about_document_answers,
                     :about_documents_path
  end

  context "when form is invalid" do
    subject { post :will_it_work_for_me, params: { locale: "en", will_it_work_for_me_form: invalid_form_answers } }

    it "stores flash errors" do
      set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)
      expect(subject).to render_template(:index)
      expect(flash[:errors]).not_to be_empty
    end
  end
end
