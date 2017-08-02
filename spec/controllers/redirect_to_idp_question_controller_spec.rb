require 'rails_helper'
require 'controller_helper'
require 'redirect_to_idp_question_examples'
require 'piwik_test_helper'

describe RedirectToIdpQuestionController do
  INTERSTITIAL_YES_RESPONSE = { interstitial_question_result: 'true' }.freeze
  INTERSTITIAL_NO_RESPONSE = { interstitial_question_result: 'false' }.freeze
  INVALID_FORM_ANSWERS = {}.freeze

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    session[:selected_idp] = { 'entity_id' => 'http://example.com/stub-idp-one-doc-question', 'simple_id' => 'stub-idp-one-doc-question', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
    session[:selected_idp_was_recommended] = true
  end

  context 'valid form' do
    include_examples 'redirect_to_idp_question',
                     'redirects to idp warning page',
                     'when user answers yes to the interstitial question',
                     INTERSTITIAL_YES_RESPONSE,
                     :redirect_to_idp_warning_path

    include_examples 'redirect_to_idp_question',
                     'redirects to idp will not work for you page ',
                     'when user answers no to the interstitial question',
                     INTERSTITIAL_NO_RESPONSE,
                     :idp_wont_work_for_you_one_doc_path
  end

  context 'when form is invalid' do
    subject { post :continue, params: { locale: 'en', interstitial_question_form: INVALID_FORM_ANSWERS } }

    it 'stores flash errors' do
      set_session_and_cookies_with_loa('LEVEL_1')
      expect(subject).to render_template(:index)
      expect(flash[:errors]).not_to be_empty
    end
  end
end
