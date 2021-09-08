require "piwik_test_helper"

shared_examples "redirect_to_idp_question" do |test_context, form_answer_description, form_variables, redirect_path|
  before(:each) do
    set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)
    set_selected_idp(entity_id: "http://example.com/stub-idp-one-doc-question", simple_id: "stub-idp-one-doc-question", levels_of_assurance: [LevelOfAssurance::LOA1, LevelOfAssurance::LOA2])
    session[:selected_idp_was_recommended] = true
    stub_piwik_request
  end

  context test_context do
    subject { post :continue, params: { locale: "en", interstitial_question_form: form_variables } }
    it "should redirect to #{redirect_path} on #{form_answer_description}" do
      expect(subject).to redirect_to(send(redirect_path))
    end
  end
end
