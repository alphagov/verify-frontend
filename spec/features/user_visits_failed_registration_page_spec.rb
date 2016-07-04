require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the failed registration page' do
  describe 'service with continue on fail flow' do
    before(:each) do
      set_session_cookies!
      page.set_rack_session(
        selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
        transaction_simple_id: 'test-rp-with-continue-on-fail'
      )
    end

    it 'includes expected content' do
      visit '/failed-registration'

      expect(page).to have_content 'Continue to register for an identity profile'
      expect(page).to have_content 'IDCorp was unable to verify your identity, but you can still submit your application.'
      expect(page).to have_link('Continue', href: redirect_to_service_error_path)
      expect(page).to have_content 'Problems verifying your identity'
      expect(page).to have_content 'IDCorp was unable to verify your identity'
      expect(page).to have_content 'There are a few reasons'
      expect(page).to have_content 'Contact IDCorp for more information'
      expect(page).to have_css 'strong', text: '100 IDCorp Lane'
      expect(page).to have_link(
        'Other ways to access register for an identity profile',
        href: other_ways_to_access_service_path)
      expect(page).to have_link('Try another certified company', href: select_documents_path)
    end
  end

  describe 'service without continue on fail flow' do
    before(:each) do
      set_session_cookies!
      page.set_rack_session(
        selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
        transaction_simple_id: 'test-rp'
      )
    end

    it 'includes expected content' do
      visit '/failed-registration'

      expect_feedback_source_to_be(page, 'FAILED_REGISTRATION_PAGE')
      expect(page).to have_content 'IDCorp was unable to verify your identity'
      expect(page).to have_content 'There are a few reasons'
      expect(page).to have_content 'Contact IDCorp for more information'
      expect(page).to have_css 'strong', text: '100 IDCorp Lane'
      expect(page).to have_link(
        'Other ways to access register for an identity profile',
        href: other_ways_to_access_service_path
      )
      expect(page).to have_link('Try another certified company', href: select_documents_path)
      expect(page).to_not have_link('Continue')
    end

    it 'displays the content in Welsh' do
      visit '/cofrestru-wedi-methu'

      expect(page).to have_css 'html[lang=cy]'
    end
  end
end
