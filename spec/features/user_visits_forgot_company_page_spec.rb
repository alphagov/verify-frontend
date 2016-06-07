require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the forgot company page' do
  before(:each) do
    set_session_cookies!
  end

  it 'includes the expected content' do
    visit '/forgot-company'

    expect_feedback_source_to_be(page, 'FORGOT_COMPANY_PAGE')
    expect(page).to have_content 'We can’t tell you which company verified you'
    expect(page).to have_link(I18n.t('navigation.back'))
  end

  it 'takes us back to the sign-in page when the Back link is clicked' do
    stub_federation
    visit '/forgot-company'
    click_link I18n.t('navigation.back')

    expect(page).to have_current_path('/sign-in')
  end

  it 'displays content in Welsh' do
    visit '/wedi-anghofio-cwmni'

    expect(page).to have_content 'Ni allwn ddweud wrthych pa gwmni wnaeth eich dilysu'
    expect(page).to have_content 'Mae GOV.UK Verify wrthi’n cael ei gyfieithu i’r Gymraeg.'
    expect(page).to have_css 'html[lang=cy]'
  end
end
