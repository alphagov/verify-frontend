require 'api_test_helper'
require 'piwik_test_helper'

shared_examples 'response_processing' do |matching_outcome, piwik_action, redirect_path|
  it "redirects to #{redirect_path} and reports \"#{piwik_action}\" to Piwik for matching outcome #{matching_outcome}" do
    set_session_and_cookies_with_loa('LEVEL_1')
    stub_piwik_request('action_name' => piwik_action)
    stub_matching_outcome(matching_outcome)
    get :index, params: { locale: 'en' }
    expect(subject).to redirect_to(send(redirect_path))
  end
end

shared_examples 'response_processing_errors' do |matching_outcome, piwik_action, error_feedback_source|
  it "renders error page and reports \"#{piwik_action}\" to Piwik for matching outcome #{matching_outcome}" do
    set_session_and_cookies_with_loa('LEVEL_1')
    stub_piwik_request('action_name' => piwik_action)
    stub_matching_outcome(matching_outcome)
    expect(subject).to receive(:render).with(
      'matching_error',
      status: 500,
      locals: { error_feedback_source: error_feedback_source }
    )
    get :index, params: { locale: 'en' }
    expect(response).to have_http_status(500)
  end
end
