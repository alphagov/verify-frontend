require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'When user visits document selection page' do
  before(:each) do
    experiment = { "short_hub_2019_q3-preview" => "short_hub_2019_q3-preview_variant_c_2_idp_short_hub" }
    set_session_and_ab_session_cookies!(experiment)
    visit '/select-documents'
  end

  it 'includes the appropriate feedback source' do
    expect_feedback_source_to_be(page, 'SELECT_DOCUMENTS_PAGE', '/select-documents')
  end

  it 'should have a header about photo identity documents' do
    expect(page).to have_content('Which of these do you have available right now?')
  end

  it 'should have a header about photo identity documents in Welsh if user selects Welsh' do
    visit '/dewis-dogfennau'
    expect(page).to have_content('Which of these do you have available right now?')
  end

  context 'with javascript enabled', js: true do
    it 'redirects to the idp picker page when selects 3 documents' do
      visit '/select-documents'

      check 'Your current driving licence, full or provisional, with your photo on it'
      check 'Your valid passport'
      check 'Your credit or debit card'
      click_button t('navigation.continue')

      expect(page).to have_current_path(choose_a_certified_company_path)
    end
  end
end
