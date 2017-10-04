require 'rails_helper'
require 'controller_helper'
require 'redirect_to_idp_question_examples'
require 'piwik_test_helper'

describe RedirectToIdpQuestionController do
  interstitial_yes_response = { interstitial_question_result: 'true' }.freeze
  interstitial_no_response = { interstitial_question_result: 'false' }.freeze
  invalid_form_answers = {}.freeze

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    session[:selected_idp] = { 'entity_id' => 'http://example.com/stub-idp-one-doc-question', 'simple_id' => 'stub-idp-one-doc-question', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
    session[:selected_idp_was_recommended] = true
  end

  context 'valid form' do
    include_examples 'redirect_to_idp_question',
                     'redirects to idp warning page',
                     'when user answers yes to the interstitial question',
                     interstitial_yes_response,
                     :redirect_to_idp_warning_path

    include_examples 'redirect_to_idp_question',
                     'redirects to idp will not work for you page ',
                     'when user answers no to the interstitial question',
                     interstitial_no_response,
                     :idp_wont_work_for_you_one_doc_path
  end

  context 'starts on correct view for loa' do
    it 'displays correct view for loa1' do
      set_session_and_cookies_with_loa('LEVEL_1')
      get :index, params: { locale: 'en' }
      expect(subject).to render_template(:redirect_to_idp_question_LOA1)
    end

    it 'displays correct view for loa2' do
      set_session_and_cookies_with_loa('LEVEL_2')
      get :index, params: { locale: 'en' }
      expect(subject).to render_template(:redirect_to_idp_question_LOA2)
    end
  end

  context 'when form is invalid' do
    subject { post :continue, params: { locale: 'en', interstitial_question_form: invalid_form_answers } }

    it 'stores flash errors and redirects to loa1' do
      set_session_and_cookies_with_loa('LEVEL_1')
      expect(subject).to render_template(:redirect_to_idp_question_LOA1)
      expect(flash[:errors]).not_to be_empty
    end

    it 'stores flash errors and redirects to loa2' do
      set_session_and_cookies_with_loa('LEVEL_2')
      expect(subject).to render_template(:redirect_to_idp_question_LOA2)
      expect(flash[:errors]).not_to be_empty
    end
  end
end
