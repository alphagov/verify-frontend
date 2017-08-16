require 'feature_helper'
require 'api_test_helper'
require 'mock_piwik_middleware'
require 'cookie_names'

RSpec.describe 'When the user visits a page' do
  let(:request_log) { double(:request_log) }

  before(:all) do
    WebMock.allow_net_connect!
  end

  before :each do
    # Add our mock piwik endpoint to the capybara server
    capybara_server = Capybara::Server.new(MockPiwikMiddleware.new(request_log))
    capybara_server.boot
    server_url = "http://#{[capybara_server.host, capybara_server.port].join(':')}/piwik.php"
    allow(PUBLIC_PIWIK).to receive(:url).and_return(server_url)
  end

  after(:all) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  context 'when JS is enabled', js: true do
    it 'sends a page view to analytics' do
      expect(request_log).to receive(:log).with(
        hash_including(
          'action_name' => 'Start - GOV.UK Verify - GOV.UK - LEVEL_2',
          'idsite' => '5'
        )
      )
      set_session_and_session_cookies!
      visit '/start'
      expect(page).to have_content 'Sign in with GOV.UK Verify'
    end

    it 'and in Welsh sends the page title in English to analytics' do
      expect(request_log).to receive(:log).with(
        hash_including(
          'action_name' => 'Start - GOV.UK Verify - GOV.UK - LEVEL_2',
          'idsite' => '5'
        )
      )
      set_session_and_session_cookies!
      visit '/dechrau'
    end

    it 'sends a page view with a custom url for error pages' do
      stub_transactions_list
      expect(request_log).to receive(:log).with(
        hash_including(
          'action_name' => 'Cookies Missing - GOV.UK Verify - GOV.UK',
          'url' => /cookies-not-found/
        )
      )
      visit '/start'
      expect(page).to have_content "If you can’t access GOV.UK Verify from a service, enable your cookies."
    end

    it 'sends an event to Piwik only when the user changes selection, on the start page' do
      stub_transactions_list
      set_session_and_session_cookies!
      expect(request_log).to receive(:log).with(
        hash_including(
          'action_name' => 'Start - GOV.UK Verify - GOV.UK - LEVEL_2'
        )
      )
      expect(request_log).to receive(:log).with(
        hash_including(
          'e_c' => 'Journey',
          'e_n' => 'user_type',
          'e_a' => 'Change to First Time'
        )
      ).exactly(1).times
      expect(request_log).not_to receive(:log).with(
        hash_including(
          'e_c' => 'Journey',
          'e_n' => 'user_type',
          'e_a' => 'Change to Sign In'
        )
      )
      visit '/start'
      choose 'start_form_selection_false', allow_label_click: true
      choose 'start_form_selection_false', allow_label_click: true
      choose 'start_form_selection_true', allow_label_click: true
    end

    it 'sends an event to Piwik when the user clicks on a proof of address radio button' do
      # set_session_and_session_cookies!
      set_session_and_ab_session_cookies!('proof_of_address_v3' => 'proof_of_address_v3_with_bank_account')
      expect(request_log).to receive(:log).with(
        hash_including(
          'action_name' => 'Proof of your address - GOV.UK Verify - GOV.UK - LEVEL_2'
        )
      )
      expect(request_log).to receive(:log).with(
        hash_including(
          'e_c' => 'Evidence',
          'e_n' => 'uk_bank_account_details',
          'e_a' => 'no'
        )
      )
      visit '/select-proof-of-address'
      choose 'select_proof_of_address_form_uk_bank_account_details_false', allow_label_click: true
    end
  end

  context 'when JS is disabled' do
    it 'sends a page view to analytics' do
      set_session_and_session_cookies!
      visit '/start'
      expect(page).to have_content 'Sign in with GOV.UK Verify'
      noscript_image = page.find(:id, 'piwik-noscript-tracker')
      expect(noscript_image).to_not be_nil
      image_src = noscript_image['src']
      expect(image_src).to match(/piwik.php\?/)
      expect(image_src).to match(/idsite=5/)
      expect(image_src).to match(/rec=1/)
      expect(image_src).to match(/rand=\d+/)
      expect(image_src).to match(/action_name=Start\+-\+GOV\.UK\+Verify\+-\+GOV\.UK\+-\+LEVEL_2/)
      expect(image_src).to_not include('url')
    end

    it 'and in Welsh sends the page title in English to analytics' do
      set_session_and_session_cookies!
      visit '/dechrau'
      noscript_image = page.find(:id, 'piwik-noscript-tracker')
      expect(noscript_image).to_not be_nil
      image_src = noscript_image['src']
      expect(image_src).to match(/action_name=Start\+-\+GOV\.UK\+Verify\+-\+GOV\.UK\+-\+LEVEL_2/)
    end

    it 'sends a page view with a custom url for error pages' do
      stub_transactions_list
      visit '/start'
      expect(page).to have_content "If you can’t access GOV.UK Verify from a service, enable your cookies."
      noscript_image = page.find(:id, 'piwik-noscript-tracker')
      expect(noscript_image).to_not be_nil
      image_src = noscript_image['src']
      expect(image_src).to match(/piwik.php\?/)
      expect(image_src).to match(/idsite=5/)
      expect(image_src).to match(/rec=1/)
      expect(image_src).to match(/rand=\d+/)
      expect(image_src).to match(/action_name=Cookies\+Missing\+-\+GOV\.UK\+Verify\+-\+GOV\.UK/)
      expect(image_src).to match(/url=[^&]+cookies-not-found/)
    end
  end
end
