require 'piwik_test_helper'

shared_examples 'will_it_work_for_me' do |test_context, form_answer_description, form_variables, redirect_path|
  let(:session_proxy) { double(:session_proxy) }

  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_1')
    session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
    session[:selected_idp_was_recommended] = true
    stub_piwik_request
  end

  context test_context do
    subject { post :will_it_work_for_me, params: { locale: 'en', will_it_work_for_me_form: form_variables } }
    it "should redirect to #{redirect_path} on #{form_answer_description}" do
      expect(ANALYTICS_REPORTER).to receive(:report).with(any_args)
      expect(subject).to redirect_to(send(redirect_path))
    end
  end
end
