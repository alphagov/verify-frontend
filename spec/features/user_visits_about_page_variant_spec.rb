require 'feature_helper'
require 'cookie_names'
require 'piwik_test_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the about page' do
  before(:each) do
    set_session_and_ab_session_cookies!('questions_light' => 'questions_light_variant')
    stub_api_idp_list_for_loa
  end

  context 'session cookie contains transaction id' do
    before(:each) do
      page.set_rack_session(transaction_simple_id: 'test-rp')
    end
    it "will display the page and report the user's selection to piwik" do
      visit '/about'

      expect(page).to have_content 'GOV.UK Verify is a secure service built to fight the growing problem of online identity theft.'
      expect_feedback_source_to_be(page, 'ABOUT_PAGE', '/about')

      expect(page).to have_link('Next', href: '/about-certified-companies')
    end

    it 'will display the about page in Welsh' do
      visit '/am'
      expect(page).to have_content 'Mae GOV.UK Verify yn wasanaeth diogel a adeiladwyd i frwydro'
      expect(page).to have_css 'html[lang=cy]'
    end

    it 'should have the eligibility content' do
      visit '/about'
      expect(page).to have_content "To use Verify, you need to:"
    end

    it 'will take user to the why-might-this-not-work-for-me-page when user clicks on the other ways link' do
      visit '/about'
      click_link('Other ways to register for an identity profile')

      expect(page).to have_current_path('/why-might-this-not-work-for-me')
    end
  end
end
