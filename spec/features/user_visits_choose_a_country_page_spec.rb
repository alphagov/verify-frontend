require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the choose a country page' do
  before(:each) do
    set_session_and_session_cookies!
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

  it 'should show something went wrong when visiting choose a country page directly with session not supporting eidas' do
    given_a_session_not_supporting_eidas

    visit '/choose-a-country'
    expect(page).to have_content 'Sorry, something went wrong'
  end

  it 'should have a heading' do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_current_path(choose_a_country_path)
    expect(page).to have_css 'h1.heading-xlarge', text: I18n.translate('hub.choose_country.heading')
  end

  it 'should have select when JS is disabled' do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_select 'js-disabled-country-picker'
  end

  it 'should have a typeahead when JS is enabled', js: true do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    expect(page).to have_css '.typeahead__wrapper'
  end

  it 'should redirect to country page (when JS is disabled)' do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    within '.js-hidden' do
      select 'Spain', from: 'country'
      click_on 'Select'
    end

    expect(page).to have_current_path('/redirect-to-country')
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

    visit '/choose-a-country'

    within '.js-show' do
      fill_in 'input-typeahead', with: 'Spain'
      click_on 'Select'
    end

    expect(page).to have_current_path('/redirect-to-country')
  end

  it 'should submit to the API (when JS is enabled)', js: true do
    given_a_session_supporting_eidas

    visit '/choose-a-country'

    within '.js-show' do
      fill_in 'input-typeahead', with: 'Netherlands'
      click_on 'Select'
    end

    expect(page).to have_current_path('/redirect-to-country')
  end
end
