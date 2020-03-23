require 'feature_helper'
require 'api_test_helper'
require 'cookie_names'

RSpec.describe 'When the user visits the about certified companies page' do
  let(:simple_id) { 'stub-idp-one' }
  let(:simple_id_loa1) { 'stub-idp-loa1' }
  let(:idp_entity_id) { 'http://idcorp.com' }

  context 'loa2' do
    before(:each) do
      stub_transactions_list
      stub_api_idp_list_for_registration(default_idps, 'LEVEL_2')
      set_session_and_session_cookies!
    end

    it 'includes the appropriate feedback source' do
      visit '/about-certified-companies'

      expect_feedback_source_to_be(page, 'ABOUT_CERTIFIED_COMPANIES_PAGE', '/about-certified-companies')
    end

    it 'displays content in Welsh' do
      visit '/am-gwmniau-ardystiedig'

      expect(page).to have_content t('hub.about_certified_companies.summary', locale: :cy)
      expect(page.body).to include t('hub.about_certified_companies.details_html', locale: :cy)
    end

    it 'displays IdPs that are enabled' do
      visit '/about-certified-companies'

      expect(page).to have_css("img[src*='/white/#{simple_id}']")
    end

    it 'will show "How companies can verify identities" section' do
      visit '/about-certified-companies'

      expect(page).to have_content t('hub.about_certified_companies.summary')
      expect(page.body).to include t('hub.about_certified_companies.details_html')
    end

    it 'will go to about identity accounts page when next is clicked' do
      visit '/about-certified-companies'
      click_link('Next')

      expect(page).to have_current_path('/about-identity-accounts')
    end
  end

  context 'loa1' do
    before(:each) do
      stub_transactions_list
      stub_api_idp_list_for_registration(default_idps, 'LEVEL_1')
      set_session_and_session_cookies!
      set_loa_in_session('LEVEL_1')
    end

    it 'includes the appropriate feedback source' do
      visit '/about-certified-companies'

      expect_feedback_source_to_be(page, 'ABOUT_CERTIFIED_COMPANIES_PAGE', '/about-certified-companies')
    end

    it 'displays content in Welsh' do
      visit '/am-gwmniau-ardystiedig'

      expect(page).to have_content t('hub.about_certified_companies.summary', locale: :cy)
      expect(page.body).to include t('hub.about_certified_companies.loa1_details_html', locale: :cy)
    end

    it 'displays IdPs that are enabled' do
      visit '/about-certified-companies'

      expect(page).to have_css("img[src*='/white/#{simple_id_loa1}']")
    end

    it 'will show "How companies can verify identities" section' do
      visit '/about-certified-companies'

      expect(page).to have_content t('hub.about_certified_companies.summary')
      expect(page.body).to include t('hub.about_certified_companies.loa1_details_html')
    end

    it 'will go to about identity accounts page when next is clicked' do
      visit '/about-certified-companies'
      click_link('Next')

      expect(page).to have_current_path('/about-identity-accounts')
    end
  end
end
