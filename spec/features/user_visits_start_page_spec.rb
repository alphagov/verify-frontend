require 'feature_helper'

RSpec.describe 'When the user visits the start page' do
  it 'will display the start page' do
    visit '/start'
    expect(page).to have_content 'Sign in with GOV.UK Verify'
  end
end
