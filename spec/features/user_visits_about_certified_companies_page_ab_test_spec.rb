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

  it 'reports custom variable to piwik for cohort a' do
    set_cookies!(CookieNames::AB_TEST => 'logos_yes')
    visit '/about-certified-companies'
    expect(page).to have_content I18n.translate('hub.about_certified_companies.a_certified_company_will_verify')
    expect(page).to have_css("img[src*='/white/#{simple_id}']")
    piwik_request = {
        '_cvar' => '{"6":["AB_TEST","logos_yes"]}'
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'reports custom variable to piwik for cohort b' do
    set_cookies!(CookieNames::AB_TEST => 'logos_no')
    visit '/about-certified-companies'
    expect(page).to have_content I18n.translate('hub.about_certified_companies.a_certified_company_will_verify_security')
    expect(page).to_not have_css("img[src*='/white/#{simple_id}']")
    piwik_request = {
        '_cvar' => '{"6":["AB_TEST","logos_no"]}'
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'does not report to piwik if cookie value is invalid' do
    set_cookies!(CookieNames::AB_TEST => 'invalid_value')
    visit '/about-certified-companies'
    expect(page).to have_content I18n.translate('hub.about_certified_companies.a_certified_company_will_verify')
    expect(page).to have_css("img[src*='/white/#{simple_id}']")
    piwik_request = {
        '_cvar' => '{"6":["AB_TEST","invalid_value"]}'
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_not_been_made
  end

  it 'cookie is not set' do
    visit '/about-certified-companies'
    expect(page).to have_content I18n.translate('hub.about_certified_companies.a_certified_company_will_verify')
    expect(page).to have_css("img[src*='/white/#{simple_id}']")
    expect(WebMock).to have_not_requested(:get, INTERNAL_PIWIK.url)
  end
end
