require 'feature_helper'

RSpec.describe 'user encounters error page' do
  let(:api_saml_endpoint) { 'http://localhost:50190/api/SAML2/SSO' }

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
