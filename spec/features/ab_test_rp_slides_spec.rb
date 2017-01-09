require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When user visits with rp_slides_tailored ab_test cookie' do
  before(:each) do
    set_session_and_session_cookies!
    cookie_hash = create_cookie_hash.merge!(ab_test: CGI.escape({ 'rp_slides' => 'rp_slides_tailored' }.to_json))
    set_cookies!(cookie_hash)
    stub_transactions_list
  end

  context 'visits about page' do
    it 'will show text tailored to the rp' do
      visit '/about'
      expect(page).to have_content 'This is tailored text for'
    end

    it 'will report to piwki' do
      visit '/about'
      piwik_request = {
        '_cvar' => '{"6":["AB_TEST","rp_slides_tailored"]}'
      }
      expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
    end
  end

  context 'visits about certified companies page' do
    it 'will show text about not needing to be an existing customer' do
      visit '/about-certified-companies'
      expect(page).to have_content "You don't need to be an exitsing customer with a company as they've built new, secure systems to verify identities."
    end
  end

  context 'visits about identity accounts page' do
    it 'will say verification takes 15 minutes' do
      visit '/about-identity-accounts'
      expect(page).to have_content 'Verifying your identity takes about 15 minutes to complete, but you only have to do it once.'
    end
  end
end
