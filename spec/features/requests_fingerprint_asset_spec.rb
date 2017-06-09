require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the start page' do
  let(:request_log) { double(:request_log) }

  context 'when JS is enabled', js: true do
    before :each do
      # Capture requests to our fingerprint endpoint using a temporary middleware
      @my_app =  Capybara.app
      Capybara.app = ->(env) {
        request = ActionDispatch::Request.new(env)
        if request.path == '/assets2/fp.gif'
          request_log.log(request.params)
        end
        @my_app.call(env)
      }
    end

    after(:each) do
      Capybara.app = @my_app
    end

    it 'requests the fingerprint asset with the fingerprint in the query params' do
      query_params_hash = nil
      expect(request_log).to receive(:log) { |arg| query_params_hash = arg }
      set_session_and_session_cookies!
      stub_api_idp_list

      visit '/start'

      expect(page).to have_content 'Sign in with GOV.UK Verify'
      expect(query_params_hash).to_not be_nil
      expect(query_params_hash['hash']).to match(/^[0-9]+\-[a-z0-9]+$/)
    end
  end

  it 'includes a reference to the fingerprint asset with the params set to noJS inside a noscript element' do
    set_session_and_session_cookies!
    stub_api_idp_list

    visit '/start'

    expect(page).to have_css('noscript[style=\'position: absolute;\'] img[src=\'/assets2/fp.gif?hash=noJS\']')
  end
end
