require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the redirect to IDP question page' do
  before(:each) do
    set_session_and_session_cookies!
  end

  it 'displays a question' do
    visit '/redirect-to-idp-question'
    expect(page).to have_content('Verifying with FancyPants')

  end


end