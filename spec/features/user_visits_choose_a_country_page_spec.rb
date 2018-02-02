require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the choose a country page' do
  let(:originating_ip) { '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>' }
  let(:location) { '/a-country-page' }
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_loa
    stub_transactions_list
    stub_countries_list
  end

  def no_eidas_session
    'no-eidas-session'
  end

  def given_a_session_supporting_eidas
    page.set_rack_session transaction_supports_eidas: true
  end

  def given_a_session_not_supporting_eidas
    page.set_rack_session(
      verify_session_id: no_eidas_session,
      transaction_supports_eidas: false
    )
  end

  def then_im_at_the_interstitial_page(locale = 'en')
    expect(page).to have_current_path("/#{t('routes.redirect_to_country', locale: locale)}")
    expect(page).to have_title t('hub.redirect_to_country.title')
    expect(page).to have_content t('hub.redirect_to_country.heading')
    expect(page).to have_content t('hub.redirect_to_country.description')
    expect(page).to have_css("input[id=SAMLRequest]", visible: false)
    expect(find("input[id=SAMLRequest]", visible: false).value).to_not be_empty

    expect(page).to have_button t('navigation.continue')
  end

  def when_i_choose_to_continue
    click_button t('navigation.continue')
  end

  it 'should show something went wrong when visiting choose a country page directly with session not supporting eidas' do
    given_a_session_not_supporting_eidas

    visit '/choose-a-country'
    expect(page).to have_content t('errors.something_went_wrong.heading')
  end

  it 'should have a heading' do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_current_path(choose_a_country_path)
  end

  it 'should have select when JS is disabled' do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_select 'js-disabled-country-picker'
  end

  it 'should have a autocomplete when JS is enabled', js: true do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_css '.autocomplete__wrapper'
  end

  it 'should redirect to country page (when JS is disabled)' do
    given_a_session_supporting_eidas
    stub_select_country_request
    stub_session_country_authn_request(originating_ip, location, false)

    visit '/choose-a-country'

    within '.js-hidden' do
      select 'Netherlands', from: 'country'
      click_on 'Select'
    end

    expect(page).to have_current_path('/redirect-to-country')

    then_im_at_the_interstitial_page
    when_i_choose_to_continue
    expect(page).to have_current_path('/a-country-page')
  end

  it 'should error when invalid form is submitted (when JS is disabled)' do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    within '.js-hidden' do
      click_on 'Select'
    end

    expect(page).to have_current_path('/choose-a-country')
    expect(page).to have_content 'Please select a country from the list'
  end

  it 'should redirect to country page (when JS is enabled)', js: true do
    given_a_session_supporting_eidas
    stub_select_country_request
    stub_session_country_authn_request(originating_ip, location, false)

    visit '/choose-a-country'

    within '.js-show' do
      fill_in 'input-autocomplete', with: 'Netherlands'
      click_on 'Select'
    end

    expect(page).to have_current_path('/a-country-page')
  end

  it 'should error when invalid country is selected (when JS is enabled)', js: true do
    given_a_session_supporting_eidas
    stub_select_country_request

    visit '/choose-a-country'

    within '.js-show' do
      fill_in 'input-autocomplete', with: 'Sweden'
      click_on 'Select'
    end

    expect(page).to have_current_path('/choose-a-country')
    expect(page).to have_content 'Please select a country from the list'
  end

  it 'policy records the country selected by the user', js: true do
    # Given the User has a list of countries to choose from
    # And the User has a session that supports eIDAS Journey
    given_a_session_supporting_eidas
    stub_select_country_request
    stub_session_country_authn_request(originating_ip, location, false)

    # When the User makes a selection from the choice of available countries
    visit '/choose-a-country'

    within '.js-show' do
      fill_in 'input-autocomplete', with: 'Netherlands'
      click_on 'Select'
    end

    # Then the User should be redirected to the 'redirect-to-country' page
    expect(page).to have_current_path('/a-country-page')

    # And API is called (and policy records the country selected by the user)
    expect(a_request(:post, policy_api_uri(select_country_endpoint("my-session-id-cookie", "NL")))).to have_been_made.once
  end

  def select_country_endpoint(session_id, country_code)
    '/policy/countries/' + session_id + '/' + country_code
  end

  def stub_select_country_request
    stub_request(:post, policy_api_uri(select_country_endpoint("my-session-id-cookie", "NL")))
        .to_return(body: '')
  end
end
