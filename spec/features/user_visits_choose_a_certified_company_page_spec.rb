require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the choose a certified company page' do
  before(:each) do
    set_session_and_session_cookies!
  end

  let(:selected_answers) {
    {
        documents: { passport: true, driving_licence: true },
        phone: { mobile_phone: true, landline: true }
    }
  }

  let(:one_doc_selected_answers) {
    {
      documents: { driving_licence: true },
      phone: { mobile_phone: true, landline: true }
    }
  }

  let(:given_a_session_with_selected_answers) {
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      selected_answers: selected_answers,
    )
  }

  let(:given_a_session_without_selected_answers) {
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      selected_answers: {
        documents: { passport: false }
      },
    )
  }

  let(:given_a_session_with_one_doc_selected_answers) {
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      selected_answers: one_doc_selected_answers,
    )
  }

  let(:given_a_session_with_no_demo_rp) {
    page.set_rack_session(
      transaction_simple_id: 'test-rp-no-demo',
      selected_answers: one_doc_selected_answers,
    )
  }

  it 'includes the appropriate feedback source' do
    given_a_session_with_selected_answers

    visit '/choose-a-certified-company'

    expect_feedback_source_to_be(page, 'CHOOSE_A_CERTIFIED_COMPANY_PAGE')
  end

  it 'displays recommended IDPs' do
    given_a_session_with_selected_answers
    visit '/choose-a-certified-company'

    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page).to have_content('Based on your answers, 3 companies can verify you now:')
    within('#matching-idps') do
      expect(page).to have_button('Choose IDCorp')
    end
  end

  it 'displays no IDPs if no recommendations' do
    given_a_session_without_selected_answers
    visit '/choose-a-certified-company'
    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page).to_not have_css('#non-matching-idps')
    expect(page).to have_content('Based on your answers, no companies can verify you now:')
  end

  it 'recommends some IDPs with a recommended profile, hides non-recommended profiles, and omits non-matching profiles' do
    set_stub_federation_no_docs_in_session
    given_a_session_with_one_doc_selected_answers
    visit '/choose-a-certified-company'

    expect(page).to have_content('Based on your answers, 2 companies can verify you now:')
    within('#matching-idps') do
      expect(page).to have_button('Choose No Docs IDP')
      expect(page).to have_button('Choose IDCorp')
      expect(page).to_not have_button('Bob’s Identity Service')
    end

    within('#non-matching-idps') do
      expect(page).to have_button('Bob’s Identity Service')
    end

    expect(page).to_not have_button('Choose Carol’s Secure ID')
  end

  it 'redirects to the redirect warning page when selecting a recommended IDP' do
    entity_id = 'http://idcorp.com'
    given_a_session_with_selected_answers
    set_stub_federation_in_session(entity_id)
    visit '/choose-a-certified-company'

    within('#matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => entity_id, 'simple_id' => 'stub-idp-one')
    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql true
  end

  it 'redirects to the redirect warning page when selecting a non-recommended IDP' do
    given_a_session_with_one_doc_selected_answers
    set_stub_federation_no_docs_in_session
    visit '/choose-a-certified-company'

    within('#non-matching-idps') do
      click_button 'Bob’s Identity Service'
    end

    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => 'other-entity-id', 'simple_id' => 'stub-idp-two')
    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql false
  end

  it 'redirects to the redirect warning page with an additional question' do
    given_a_session_with_one_doc_selected_answers
    set_stub_federation_one_doc_idp_in_session
    visit '/choose-a-certified-company'

    within('#matching-idps') do
      click_button 'Choose FancyPants'
    end

    expect(page).to have_current_path(redirect_to_idp_question_path)
    expect(page).to have_content('Verifying with FancyPants')
  end

  it 'redirects to the redirect warning page without additional question for two docs' do
    given_a_session_with_selected_answers
    set_stub_federation_one_doc_idp_in_session
    visit '/choose-a-certified-company'

    within('#matching-idps') do
      click_button 'Choose FancyPants'
    end

    expect(page).to have_current_path(redirect_to_idp_warning_path)
  end

  it 'records details in session when a recommended IdP is selected' do
    given_a_session_with_selected_answers
    visit '/choose-a-certified-company'

    within('#matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql true
    expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one')
  end

  it 'rejects unrecognised simple ids' do
    given_a_session_with_selected_answers
    visit '/choose-a-certified-company'

    first('input[value="http://idcorp.com"]', visible: false).set('bob')
    within('#matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page).to have_content(I18n.translate('errors.page_not_found.title'))
    expect(page.get_rack_session['selected_idp']).to be_nil
    expect(page.get_rack_session['selected_idp_was_recommended']).to be_nil
  end

  it 'redirects to the choose a certified company about page when selecting About link' do
    given_a_session_with_selected_answers
    visit '/choose-a-certified-company'

    click_link 'About IDCorp'

    expect(page).to have_current_path(choose_a_certified_company_about_path('stub-idp-one'))
  end

  it 'displays the page in Welsh' do
    given_a_session_with_selected_answers

    visit '/dewis-cwmni-ardystiedig'
    expect(page).to have_title 'Dewiswch gwmni ardystiedig - GOV.UK Verify - GOV.UK'
    expect(page).to have_css 'html[lang=cy]'
  end

  context 'when an IDP has no recommended profiles' do
    it 'will show the IDP in demo periods as recommended when the transaction allows them' do
      given_a_session_with_one_doc_selected_answers

      visit choose_a_certified_company_path

      within('#matching-idps') do
        expect(page).to have_content('Choose Demo IDP')
      end
    end

    it 'will show IDP in demo periods as non-recommended when the transaction does not allow them' do
      given_a_session_with_no_demo_rp

      visit choose_a_certified_company_path

      within('#non-matching-idps') do
        expect(page).to have_content('Choose Demo IDP', count: 1)
      end
    end
  end
end
