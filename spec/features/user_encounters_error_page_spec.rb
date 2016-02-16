require 'feature_helper'

RSpec.describe 'user encounters error page' do
  let(:api_saml_endpoint) { api_uri('session') }
  let(:api_transactions_endpoint) { 'http://localhost:50190/api/transactions' }
  let(:session_start_time) { create_session_start_time_cookie }

  transactions = {
      'public' => [
          {'simpleId' => 'test-rp', 'entityId' => 'some-entity-id', 'homepage' => 'http://localhost:50130/test-rp'}
      ],
      'private' => [
          {'simpleId' => 'some-simple-id', 'entityId' => 'some-entity-id'}
      ]
  }

  it 'will present the user with a list of transactions' do
    stub_request(:post, api_saml_endpoint).to_return(status: 500)
    stub_request(:get, api_transactions_endpoint).to_return(body: transactions.to_json, status: 200)
    visit '/test-saml'
    click_button "saml-post"
    expect(page).to have_content "Sorry, something went wrong"
    expect(page).to have_link "Register for an identity profile", href: "http://localhost:50130/test-rp"
  end

  it 'will present error page when timeout occurs in upstream systems' do
    stub_request(:post, api_saml_endpoint).to_timeout
    visit '/test-saml'
    click_button "saml-post"
    expect(page).to have_content "Sorry, something went wrong"
  end

  it 'will present error page when standard error occurs in upstream systems' do
    stub_request(:post, api_saml_endpoint).to_raise(StandardError)
    visit '/test-saml'
    click_button "saml-post"
    expect(page).to have_content "Sorry, something went wrong"
  end
end
