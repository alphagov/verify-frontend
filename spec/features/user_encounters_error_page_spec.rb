require 'feature_helper'

RSpec.describe 'user encounters error page' do
  let(:api_saml_endpoint) { api_uri('session') }
  let(:api_transactions_endpoint) { 'http://localhost:50190/api/transactions' }
  let(:session_start_time) { create_session_start_time_cookie }


  it 'will present the user with a list of transactions' do
    stub_transactions_list
    stub_request(:post, api_saml_endpoint).to_return(status: 500)
    visit '/test-saml'
    click_button "saml-post"
    expect(page).to have_content "Sorry, something went wrong"
    expect(page).to have_link "Register for an identity profile", href: "http://localhost:50130/test-rp"
  end

  it 'will present the user with no list of transactions if we cant read the errors' do
    allow(Rails.logger).to receive(:error)
    expect(Rails.logger).to receive(:error).with(kind_of(KeyError)).at_least(:once)
    bad_transactions_json = {
        'public' => [{'homepage' => 'http://localhost:50130/test-rp' }],
        'private' => []
    }
    stub_request(:post, api_saml_endpoint).to_return(status: 500)
    stub_request(:get, api_transactions_endpoint).to_return(body: bad_transactions_json.to_json, status: 200)
    visit '/test-saml'
    click_button "saml-post"
    expect(page).to have_content "Sorry, something went wrong"
    expect(page).to_not have_content "Find the service you were using to start again"
  end

  it 'will present error page when timeout occurs in upstream systems' do
    stub_request(:post, api_saml_endpoint).to_timeout
    stub_transactions_list
    visit '/test-saml'
    click_button "saml-post"
    expect(page).to have_content "Sorry, something went wrong"
  end

  it 'will present error page when standard error occurs in upstream systems' do
    stub_request(:post, api_saml_endpoint).to_raise(StandardError)
    stub_transactions_list
    visit '/test-saml'
    click_button "saml-post"
    expect(page).to have_content "Sorry, something went wrong"
  end
end
