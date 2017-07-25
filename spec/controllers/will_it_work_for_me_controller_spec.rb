require 'rails_helper'
require 'controller_helper'
require 'will_it_work_for_me_examples'
require 'piwik_test_helper'

describe WillItWorkForMeController do
  PROCEED_TO_SELECT_DOCUMENT_ANSWERS = { above_age_threshold: 'true', resident_last_12_months: 'true' }.freeze
  NOT_OLD_ENOUGH_ANSWERS = { above_age_threshold: 'false', resident_last_12_months: 'true' }.freeze
  NOT_OLD_ENOUGH_AND_NO_ADDRESS_ANSWERS = { above_age_threshold: 'false', resident_last_12_months: 'false', not_resident_reason: 'NoAddress' }.freeze
  NOT_OLD_ENOUGH_AND_NOT_RESIDENT_ANSWERS = { above_age_threshold: 'false', resident_last_12_months: 'false', not_resident_reason: 'AddressButNotResident' }.freeze
  NOT_OLD_ENOUGH_AND_NOT_RESIDENT_MOVED_RECENTLY_ANSWERS = { above_age_threshold: 'false', resident_last_12_months: 'false', not_resident_reason: 'MovedRecently' }.freeze
  MOVED_TO_UK_LAST_YEAR_ANSWERS = { above_age_threshold: 'true', resident_last_12_months: 'false', not_resident_reason: 'MovedRecently' }.freeze
  NON_RESIDENT_ANSWERS = { above_age_threshold: 'true', resident_last_12_months: 'false', not_resident_reason: 'AddressButNotResident' }.freeze
  NO_UK_ADDRESS_ANSWERS = { above_age_threshold: 'true', resident_last_12_months: 'false', not_resident_reason: 'NoAddress' }.freeze
  INVALID_FORM_ANSWERS = { above_age_threshold: 'true' }.freeze

  context 'valid form' do
    before :each do
      stub_piwik_request('action_name' => 'Can I be Verified Next')
    end

    include_examples 'will_it_work_for_me',
                     'redirects to might not work for you if moved in recently',
                     'user has moved to the UK in the last year',
                     MOVED_TO_UK_LAST_YEAR_ANSWERS,
                     :why_might_this_not_work_for_me_path

    include_examples 'will_it_work_for_me',
                     'redirects to might not work for you if underage',
                     'user is less than 20 yrs old',
                     NOT_OLD_ENOUGH_ANSWERS,
                     :why_might_this_not_work_for_me_path

    include_examples 'will_it_work_for_me',
                     'redirects to will not work without a UK address page',
                     'user is less than 20 years old and does not have a UK address',
                     NOT_OLD_ENOUGH_AND_NO_ADDRESS_ANSWERS,
                     :will_not_work_without_uk_address_path

    include_examples 'will_it_work_for_me',
                     'redirects to overseas page if user has UK address but does not live in the UK',
                     'user is less than 20 years old, has a UK Address, but does not live in the UK',
                     NOT_OLD_ENOUGH_AND_NOT_RESIDENT_ANSWERS,
                     :may_not_work_if_you_live_overseas_path

    include_examples 'will_it_work_for_me',
                     'redirects to overseas page if user has UK address but does not live in the UK',
                     'user is less than 20 years old, has a UK Address, but does not live in the UK',
                     NOT_OLD_ENOUGH_AND_NOT_RESIDENT_MOVED_RECENTLY_ANSWERS,
                     :why_might_this_not_work_for_me_path

    include_examples 'will_it_work_for_me',
                     'redirects to the will not work page if user has no UK address',
                     'user is over 20 years old, but does not have a UK address',
                     NO_UK_ADDRESS_ANSWERS,
                     :will_not_work_without_uk_address_path

    include_examples 'will_it_work_for_me',
                     'redirects to overseas page if user has UK address but does not live in the UK',
                     'user is over 20 years old, has a UK address, but does not live in the UK',
                     NON_RESIDENT_ANSWERS,
                     :may_not_work_if_you_live_overseas_path

    include_examples 'will_it_work_for_me',
                     'redirects to select documents path if user is over 20 and lives in the UK',
                     'user is over 20 years old, and lives in the UK',
                     PROCEED_TO_SELECT_DOCUMENT_ANSWERS,
                     :select_documents_path
  end

  context 'when form is invalid' do
    subject { post :will_it_work_for_me, params: { locale: 'en', will_it_work_for_me_form: INVALID_FORM_ANSWERS } }

    it 'stores flash errors' do
      set_session_and_cookies_with_loa('LEVEL_1')
      expect(subject).to render_template(:index)
      expect(flash[:errors]).not_to be_empty
    end
  end
end
