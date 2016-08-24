require 'feature_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the about page' do
  before(:each) do
    set_session_and_session_cookies!
  end

  context 'session cookie contains transaction id' do
    before(:each) do
      page.set_rack_session(transaction_simple_id: 'test-rp')
    end
    it "will display the page and report the user's selection to piwik" do
      visit '/about'

      expect(page).to have_content 'GOV.UK Verify is a scheme to fight the growing problem of online identity theft'
      expect_feedback_source_to_be(page, 'ABOUT_PAGE')

      expect(page).to have_link('Next', href: '/about-certified-companies')
      piwik_request = {
          '_cvar' => '{"1":["RP","analytics description for test-rp"]}',
          'action_name' => 'The Yes option was selected on the start page',
      }
      expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
    end

    it 'will display the about page in Welsh' do
      visit '/am'
      expect(page).to have_content 'GOV.UK Verify yn gynllun i frwydro yn erbyn'
      expect(page).to have_css 'html[lang=cy]'
    end
  end
end
