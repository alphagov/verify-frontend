require 'feature_helper'
require 'i18n'

RSpec.describe 'When the user visits the choose a certified company page' do
  before(:each) do
    set_session_cookies!
  end

  it 'includes the appropriate feedback source' do
    stub_federation
    visit '/choose-a-certified-company'

    expect_feedback_source_to_be(page, 'CHOOSE_A_CERTIFIED_COMPANY')
  end

  it 'passes selected evidence on to why-companies page', js: true do
    stub_federation

    visit '/choose-a-certified-company?selected-evidence=driving_licence&selected-evidence=passport&selected-evidence=non_uk_id_document'
    click_link 'Why there’s a choice of companies'

    expect(page).to have_current_path(why_companies_path, only_path: true)
    actual_evidence = query_params.fetch('selected-evidence', []).to_set
    expected_evidence = %w(driving_licence passport non_uk_id_document).to_set
    expect(actual_evidence).to eql expected_evidence
  end

  it 'displays recommended IDPs', js: true do
    stub_federation
    visit '/choose-a-certified-company?selected-evidence=mobile_phone&selected-evidence=driving_licence'

    expect(page).to have_current_path(choose_a_certified_company_path, only_path: true)
    expect(page).to have_content('Based on your answers, 3 companies can verify you now:')
    within('#matching-idps') do
      expect(page).to have_button('Choose IDCorp')
    end
    expect(page).to_not have_css('#non-matching-idps')
  end

  it 'displays only non recommended IDPs if no recommendations' do
    stub_federation
    visit '/choose-a-certified-company'
    expect(page).to have_current_path(choose_a_certified_company_path, only_path: true)
    within('#non-matching-idps') do
      expect(page).to have_content('Based on your answers, these companies are unlikely to verify you now:')
      expect(page).to have_button('Choose IDCorp')
    end
    expect(page).to have_content('Based on your answers, no companies can verify you now:')
  end

  it 'recommends some IDPs and hides others' do
    stub_federation_no_docs
    visit '/choose-a-certified-company'

    expect(page).to have_content('Based on your answers, 1 company can verify you now:')
    within('#matching-idps') do
      expect(page).to have_button('Choose No Docs IDP')
      expect(page).to_not have_button('Choose IDCorp')
    end

    within('#non-matching-idps') do
      expect(page).to have_button('Choose IDCorp')
    end
  end

  it 'redirects to the redirect warning page when selecting the recommended IDP', js: true do
    entity_id = 'http://idcorp.com'
    stub_federation(entity_id)
    visit '/choose-a-certified-company?selected-evidence=mobile_phone&selected-evidence=passport'

    within('#non-matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page).to have_current_path(redirect_to_idp_warning_path, only_path: true)
    expect(query_params['selected-evidence']).to eql %w(mobile_phone passport)
    expect(query_params['recommended-idp']).to eql ['false']
    expect(query_params['selected-idp']).to eql [entity_id]
  end
end
