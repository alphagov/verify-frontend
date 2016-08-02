require 'feature_helper'
require 'api_test_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the about certified companies page' do
  let(:simple_id) { 'stub-idp-one' }
  let(:idp_entity_id) { 'http://idcorp.com' }

  before(:each) do
    body = { 'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idpcorp.com' }], 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-id' }
    stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
    stub_transactions_list
    set_session_cookies!
  end

  context 'during ab testing' do
    it 'shows logos when no ab_test cookie is present' do
      visit '/about-certified-companies'
      expect(page).to have_css("img[src*='/white/#{simple_id}']")
    end

    it 'shows logos when ab_test cookie value is "logos_yes"' do
      set_cookies!(CookieNames::AB_TEST => 'logos_yes')
      visit '/about-certified-companies'
      expect(page).to have_css("img[src*='/white/#{simple_id}']")
    end

    it 'does not show logos when ab_test cookie value is "logos_no"' do
      set_cookies!(CookieNames::AB_TEST => 'logos_no')
      visit '/about-certified-companies'
      expect(page).to_not have_css("img[src*='/white/#{simple_id}']")
    end
  end
end
