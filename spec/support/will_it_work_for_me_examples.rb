require "piwik_test_helper"

shared_examples "will_it_work_for_me" do |test_context, form_answer_description, form_variables, redirect_path|
  before(:each) do
    set_session_and_cookies_with_loa(LevelOfAssurance::LOA1)
    set_selected_idp(entity_id: "http://idcorp.com", simple_id: "stub-idp-one", levels_of_assurance: [LevelOfAssurance::LOA1, LevelOfAssurance::LOA2])
    session[:selected_idp_was_recommended] = true
  end

  context test_context do
    subject { post :will_it_work_for_me, params: { locale: "en", will_it_work_for_me_form: form_variables } }
    it "should redirect to #{redirect_path} on #{form_answer_description}" do
      expect(subject).to redirect_to(send(redirect_path))
    end
  end
end
