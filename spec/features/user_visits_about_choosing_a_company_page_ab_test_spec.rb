require 'feature_helper'
require 'cookie_names'
require 'api_test_helper'

RSpec.describe 'When the user visits the about choosing a company page' do
  before(:each) do
    set_session_and_session_cookies!
  end

  let(:given_an_abtest_with_control_group) { set_cookies!(CookieNames::AB_TEST => CGI.escape({ 'right_company' => 'right_company_control' }.to_json)) }
  let(:given_an_abtest_with_more_info_group) { set_cookies!(CookieNames::AB_TEST => CGI.escape({ 'right_company' => 'right_company_more_info' }.to_json)) }

  context 'with control ab test group cookie' do
    before(:each) do
      given_an_abtest_with_control_group
      visit '/about-choosing-a-company'
    end

    it 'will report to piwik' do
      piwik_request = {
        '_cvar' => '{"6":["AB_TEST","right_company_control"]}'
      }
      expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
    end

    it 'will see default text' do
      expect(page).to have_content 'Certified companies have different ways to verify identities, for example by checking identity documents, or providing an app'
    end
  end

  context 'with more info ab test group cookie' do
    before(:each) do
      given_an_abtest_with_more_info_group
      visit '/about-choosing-a-company'
    end

    it 'will report to piwik' do
      piwik_request = {
        '_cvar' => '{"6":["AB_TEST","right_company_more_info"]}'
      }
      expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
    end

    it 'will see default text' do
      expect(page).to have_content 'These systems work by checking'
    end
  end
end
