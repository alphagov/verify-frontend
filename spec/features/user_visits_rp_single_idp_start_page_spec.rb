require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the start page' do
  it 'will display the start page in English' do
    stub_transactions_list
    stub_translations
    visit '/single-start/test-rp'
    expect(page).to have_content "This is the Single IDP Start Page Content"
    expect(page).to have_link "Sign In", href: "http://localhost:50130/success?rp-name=test-rp"
  end
end
