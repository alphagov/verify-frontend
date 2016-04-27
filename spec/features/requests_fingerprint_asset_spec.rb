require 'feature_helper'
require 'mock_fingerprint_middleware'
require 'sinatra/base'

RSpec.describe 'When the user visits the start page' do
  let(:request_log) { double(:request_log) }

  before(:all) do
    WebMock.allow_net_connect!
  end

  before :each do
    # Add our mock fingerprint endpoint to the capybara server
    capybara_server = Capybara::Server.new(MockFingerprintMiddleware.new(request_log))
    capybara_server.boot
    server_url = "http://#{[capybara_server.host, capybara_server.port].join(':')}/assets2/fp.gif"
    allow(FINGERPRINT_CONFIG).to receive(:endpoint).and_return(server_url)
  end

  after(:all) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  context 'when JS is enabled', js: true do
    it 'requests the fingerprint asset with the fingerprint in the query params' do
      query_params_hash = nil
      expect(request_log).to receive(:log) { |arg| query_params_hash = arg }
      set_session_cookies!

      visit '/start'

      expect(page).to have_content 'Sign in with GOV.UK Verify'
      expect(query_params_hash).to_not be_nil
      expect(query_params_hash['hash']).to match(/^4\-[a-z0-9]+$/)
    end
  end

  it 'includes a reference to the fingerprint asset with the params set to noJS inside a noscript element' do
    set_session_cookies!
    visit '/start'

    expect(page).to have_css('noscript[style=\'position: absolute;\'] img[src=\'/assets2/fp.gif?hash=noJS\']')
  end
end
