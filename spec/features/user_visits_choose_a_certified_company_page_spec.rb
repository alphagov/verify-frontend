require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the choose a certified company page' do
  before(:each) do
    set_session_cookies!
  end

  let(:selected_evidence) { { documents: [:passport, :driving_licence], phone: [:mobile_phone] } }
  let(:given_a_session_with_selected_evidence) {
    page.set_rack_session(
      selected_evidence: selected_evidence,
    )
  }

  let(:given_a_session_without_selected_evidence) {
    page.set_rack_session(
      selected_evidence: {},
    )
  }

  it 'includes the appropriate feedback source' do
    stub_federation
    visit '/choose-a-certified-company'

    expect_feedback_source_to_be(page, 'CHOOSE_A_CERTIFIED_COMPANY_PAGE')
  end

  it 'displays recommended IDPs' do
    stub_federation
    given_a_session_with_selected_evidence
    visit '/choose-a-certified-company'

    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page).to have_content('Based on your answers, 3 companies can verify you now:')
    within('#matching-idps') do
      expect(page).to have_button('Choose IDCorp')
    end
    expect(page).to_not have_css('#non-matching-idps')
  end

  it 'displays only non recommended IDPs if no recommendations' do
    stub_federation
    given_a_session_without_selected_evidence
    visit '/choose-a-certified-company'
    expect(page).to have_current_path(choose_a_certified_company_path)
    within('#non-matching-idps') do
      expect(page).to have_button('Choose IDCorp')
    end
    expect(page).to have_content('Based on your answers, no companies can verify you now:')
    expect(page).to have_content('We’ve filtered out 3 companies, as they’re unlikely to be able to verify you based on your answers.')
  end

  it 'recommends some IDPs and hides others' do
    stub_federation_no_docs
    given_a_session_without_selected_evidence
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

  it 'redirects to the redirect warning page when selecting a non-recommended IDP' do
    entity_id = 'http://idcorp.com'
    stub_federation(entity_id)
    visit '/choose-a-certified-company'

    within('#non-matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => entity_id, 'simple_id' => 'stub-idp-one')
    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql false
  end

  it 'records details in session when a recommended IdP is selected' do
    stub_federation
    given_a_session_with_selected_evidence
    visit '/choose-a-certified-company'

    within('#matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql true
    expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one')
  end

  it 'rejects unrecognised simple ids' do
    stub_federation
    given_a_session_with_selected_evidence
    visit '/choose-a-certified-company'

    first('input[value=stub-idp-one]', visible: false).set('bob')
    within('#matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page).to have_content(I18n.translate('errors.page_not_found.title'))
    expect(page.get_rack_session['selected_idp']).to be_nil
    expect(page.get_rack_session['selected_idp_was_recommended']).to be_nil
  end

  it 'redirects to the choose a certified company about page when selecting About link' do
    entity_id = 'http://idcorp.com'
    stub_federation(entity_id)
    visit '/choose-a-certified-company'

    click_link 'About IDCorp'

    expect(page).to have_current_path(choose_a_certified_company_about_path('stub-idp-one'))
  end

  it 'displays the page in Welsh' do
    stub_federation
    visit '/dewis-cwmni-ardystiedig'
    expect(page).to have_title 'Dewiswch gwmni ardystiedig - GOV.UK Verify - GOV.UK'
    expect(page).to have_css 'html[lang=cy]'
  end
end
