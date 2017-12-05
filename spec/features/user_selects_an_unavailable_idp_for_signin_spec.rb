require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'when user visits sign-in page with an unavailable IDP configured' do
  def given_api_requests_have_been_mocked!
    stub_session_select_idp_request('an-encrypted-entity-id')
    stub_session_idp_authn_request('<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>', 'idp-location', false)
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
  end

  def given_im_on_the_sign_in_page
    visit sign_in_en_path
  end

  def unavailable_idp_info_page(simple_id)
    "/certified-company-unavailable/#{simple_id}"
  end

  button_text = I18n.t('hub.signin.select_idp', display_name: 'Unavailable IDP')

  context 'the API says the IDP is actually available' do
    before(:each) do
      set_session_and_session_cookies!
      stub_api_idp_list_for_sign_in([
              { 'simpleId' => 'stub-idp-one', 'entityId' => 'http://idcorp.com', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
              { 'simpleId' => 'stub-idp-two', 'entityId' => 'other-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
              { 'simpleId' => 'stub-idp-three', 'entityId' => 'a-different-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) },
              { 'simpleId' => 'stub-idp-unavailable', 'entityId' => 'unavailable-entity-id', 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) }
            ])
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
    end

    it 'will allow the user to choose the IDP as usual' do
      click_button(button_text)
      expect(page).to have_current_path(redirect_to_idp_sign_in_path)
    end

    it 'will respond with a 404 if the user visits the certified company unavailable page for that IDP' do
      visit certified_company_unavailable_path('stub-idp-unavailable')
      expect(page).to have_content('This page can’t be found')
    end
  end

  context 'API does not return IDP as available' do
    before(:each) do
      set_session_and_session_cookies!
      stub_api_idp_list_for_sign_in
      given_api_requests_have_been_mocked!
      given_im_on_the_sign_in_page
    end

    it 'will display the correct information on the unavailable IDP page' do
      click_link(button_text)
      expect(page).to have_title(I18n.t('hub.certified_company_unavailable.title'))
      expect(page).to have_link(I18n.t('hub.certified_company_unavailable.verify_another_company_link'), href: about_certified_companies_path)

      expect(page).to have_content 'Other ways to register for an identity profile'
      expect(page).to have_content 'If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile'
      expect(page).to have_link 'here', href: 'http://www.example.com'
    end

    it 'the certified company unavailable page will respond with a 404 if an IDP is not set to unavailable' do
      visit certified_company_unavailable_path('stub-idp-one')
      expect(page).to have_content('This page can’t be found')
    end
  end
end
