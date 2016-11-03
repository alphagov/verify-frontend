require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the start page' do
  let(:simple_id) { 'stub-idp-one' }
  let(:idp_entity_id) { 'http://idcorp.com' }

  before(:each) do
    body = { 'idps' => [{ 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idpcorp.com' }], 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-id' }
    stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
    stub_transactions_list
    set_session_and_session_cookies!
  end

  it 'reports custom variable to piwik for cohort a and does not show additional questions' do
    set_cookies!(CookieNames::AB_TEST => CGI.escape({ 'select_documents' => 'select_documents_control' }.to_json))
    visit '/start'
    piwik_request = {
        '_cvar' => '{"6":["AB_TEST","select_documents_control"]}'
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once

    visit '/select-documents'
    expect(page).to_not have_content I18n.translate('hub.select_documents.question.uk_bank_account_details')
    expect(page).to_not have_content I18n.translate('hub.select_documents.question.debit_card')
    expect(page).to_not have_content I18n.translate('hub.select_documents.question.credit_card')
    expect(page).to have_content I18n.translate('hub.select_documents.question.no_documents')
  end

  it 'reports custom variable to piwik for cohort b and does not show additional questions' do
    set_cookies!(CookieNames::AB_TEST => CGI.escape({ 'select_documents' => 'select_documents_new_questions_profile_change' }.to_json))
    visit '/start'
    piwik_request = {
        '_cvar' => '{"6":["AB_TEST","select_documents_new_questions_profile_change"]}'
    }
    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once

    visit '/select-documents'
    expect(page).to have_content I18n.translate('hub.select_documents.question.uk_bank_account_details')
    expect(page).to have_content I18n.translate('hub.select_documents.question.debit_card')
    expect(page).to have_content I18n.translate('hub.select_documents.question.credit_card')
    expect(page).to_not have_content I18n.translate('hub.select_documents.question.no_documents')
  end
end
