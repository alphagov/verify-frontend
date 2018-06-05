require 'feature_helper'
require 'cookie_names'
require 'piwik_test_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the about page on variant' do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_loa
    set_session_and_ab_session_cookies!('short_hub_v3' => 'short_hub_v3_variant')
  end

  context 'session cookie contains transaction id' do
    before(:each) do
      page.set_rack_session(transaction_simple_id: 'test-rp')
    end
    it "will display the page and report the user's selection to piwik" do
      visit '/about'

      expect(page).to have_content 'Set up a free account with one of GOV.UK Verify\'s certified identity providers.'
      expect_feedback_source_to_be(page, 'ABOUT_PAGE', '/about')

      expect(page).to have_link('Set up an identity account', href: '/will-it-work-for-me')
    end
  end
end
