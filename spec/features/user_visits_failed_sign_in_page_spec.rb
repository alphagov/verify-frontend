require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the failed sign in page' do
  before(:each) do
    set_session_and_session_cookies!
  end

  context '#idp' do
    before(:each) do
      stub_api_idp_list_for_loa
      page.set_rack_session(
          selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' }
      )
    end

    it 'includes expected content' do
      visit '/failed-sign-in'

      expect_feedback_source_to_be(page, 'FAILED_SIGN_IN_PAGE', '/failed-sign-in')
      expect(page).to have_title t('hub.failed_sign_in.title')
      expect(page).to have_content t('hub.failed_sign_in.heading', display_name: 'IDCorp')
      expect(page.body).to include t('hub.failed_sign_in.reasons_html')
      expect(page).to have_link t('hub.failed_sign_in.start_again'), href: start_path
    end

    it 'displays the content in Welsh' do
      visit '/mewngofnodi-wedi-methu'

      expect(page).to have_css 'html[lang=cy]'
    end
  end

  context '#country' do
    before(:each) do
      stub_countries_list
      page.set_rack_session selected_country: { entity_id: 'http://stub-country.uk', simple_id: 'YY', enabled: true }
    end

    it 'includes expected content' do
      visit '/failed-country-sign-in'

      expect_feedback_source_to_be(page, 'FAILED_COUNTRY_SIGN_IN_PAGE', '/failed-country-sign-in')
      expect(page).to have_title t('hub.failed_country_sign_in.title')
      expect(page).to have_content t('hub.failed_country_sign_in.heading', country_name: 'Stub Country')
      expect(page.body).to have_content t('hub.failed_country_sign_in.online')
      expect(page).to have_link t('hub.failed_country_sign_in.online_link'), href: prove_identity_path
      expect(page.body).to have_content t('hub.failed_country_sign_in.offline')
    end

    it 'should redirect to prove-identity page on matching error for an eIDAS journey' do
      visit '/failed-country-sign-in'
      click_on t('hub.failed_country_sign_in.online_link')

      expect(page).to have_current_path('/prove-identity')
    end

    it 'displays the content in Welsh' do
      visit '/methu-mewngofnodi-gwlad'

      expect(page).to have_css 'html[lang=cy]'
    end
  end
end
