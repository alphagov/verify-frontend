require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits a page that triggers an API call when the session has soft timed out' do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list
  end

  it 'should render the soft session timeout page when SESSION_TIMEOUT received from the API' do
    stub_api_returns_error('SESSION_TIMEOUT')
    visit redirect_to_idp_register_path
    expect(page).to have_link(href: '/redirect-to-service/error', class: 'button')
  end
end
