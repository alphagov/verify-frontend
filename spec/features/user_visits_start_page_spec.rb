require 'feature_helper'

RSpec.describe 'When the user visits the start page' do
  it 'will display the start page' do
    visit '/start'
    expect(page).to have_content 'Sign in with GOV.UK Verify'
    expect(page).to have_css 'html[lang=en]'
  end
  it 'will display the start page in Welsh' do
    visit '/dechrau'
    expect(page).to have_content 'Mewngofnodi gyda GOV.UK Verify'
    expect(page).to have_css 'html[lang=cy]'
  end
end
