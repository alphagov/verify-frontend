require 'feature_helper'
require 'api_test_helper'
RSpec.feature 'current identity providers are stored in session' do
  it 'asks for the identity providers only once' do
    set_session_and_session_cookies!
    stub_identity_providers_request = stub_federation
    visit choose_a_certified_company_path
    visit choose_a_certified_company_path
    expect(stub_identity_providers_request).to have_been_made.once
  end

  it 'will work across multiple controllers' do
    set_session_and_session_cookies!
    stub_identity_providers_request = stub_federation
    visit about_certified_companies_path
    visit sign_in_path
    expect(stub_identity_providers_request).to have_been_made.once
  end
end
