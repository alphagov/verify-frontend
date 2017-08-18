require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the about certified companies page from an LOA1 relying party' do
  before(:each) do
    stub_transactions_list
    stub_api_idp_list
    set_session!
    set_loa_in_session('LEVEL_1')
  end

  it 'should not display any logos when the ab test cookie is loa1_logos_control' do
    set_cookies_and_ab_test_cookie!('loa1_logos' => 'loa1_logos_control')
    visit '/about-certified-companies'
    expect(page).to_not have_css('ul.list-companies')
  end

  it 'should display LOA1 IDPs logos when the ab test cookie is loa1_logos_available' do
    set_cookies_and_ab_test_cookie!('loa1_logos' => 'loa1_logos_available')
    visit '/about-certified-companies'
    expect(page).to have_css('ul.list-companies li', count: 1)
  end

  it 'should display all IDP logos when the ab test cookie is loa1_logos_all' do
    set_cookies_and_ab_test_cookie!('loa1_logos' => 'loa1_logos_all')
    visit '/about-certified-companies'
    expect(page).to have_css('ul.list-companies li', count: 5)
  end
end
