require 'feature_helper'
require 'api_test_helper'
require 'i18n'

describe 'When the user visits the choose a certified company page' do
  before(:each) do
    set_session_and_ab_session_cookies!
    stub_api_idp_list
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


  let(:given_a_session_with_two_docs_selected_answers) {
    given_a_session_with_selected_answers
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

  let(:reluctant_mob_installation_session) {
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      reluctant_mob_installation: true,
      selected_answers: selected_answers,
    )
  }

  it 'includes the appropriate feedback source' do
    given_a_session_with_selected_answers

    visit '/choose-a-certified-company'

    expect_feedback_source_to_be(page, 'CHOOSE_A_CERTIFIED_COMPANY_PAGE', '/choose-a-certified-company')
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
    stub_api_no_docs_idps
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
    stub_api_idp_list([{ 'simpleId' => 'stub-idp-one', 'entityId' => entity_id, 'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) }])
    visit '/choose-a-certified-company'

    within('#matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session_key('selected_idp')).to include('entity_id' => entity_id, 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql true
  end

  it 'redirects to the redirect warning page when selecting a non-recommended IDP' do
    given_a_session_with_one_doc_selected_answers
    stub_api_no_docs_idps
    visit '/choose-a-certified-company'

    within('#non-matching-idps') do
      click_button 'Bob’s Identity Service'
    end

    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => 'other-entity-id', 'simple_id' => 'stub-idp-two', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql false
  end

  context 'choosing an IDP that displays a question for certain evidence' do
    before :each do
      stub_api_idp_list([{
                             'simpleId' => 'stub-idp-one-doc-question',
                             'entityId' => 'http://fancypants.com',
                             'levelsOfAssurance' => %w(LEVEL_1 LEVEL_2) }])
    end

    it 'redirects to the interstitial question page with an additional question when having one doc' do
      given_a_session_with_one_doc_selected_answers
      visit '/choose-a-certified-company'

      within('#matching-idps') do
        click_button 'Choose FancyPants'
      end

      expect(page).to have_current_path(redirect_to_idp_question_path)
      expect(page.get_rack_session_key('selected_idp')).to include('simple_id' => 'stub-idp-one-doc-question', 'entity_id' => 'http://fancypants.com', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    end

    it 'redirects to the warning page without additional question for two docs' do
      given_a_session_with_two_docs_selected_answers
      visit '/choose-a-certified-company'

      within('#matching-idps') do
        click_button 'Choose FancyPants'
      end

      expect(page).to have_current_path(redirect_to_idp_warning_path)
      expect(page.get_rack_session_key('selected_idp')).to include('simple_id' => 'stub-idp-one-doc-question', 'entity_id' => 'http://fancypants.com', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
    end
  end

  it 'records details in session when a recommended IdP is selected' do
    given_a_session_with_selected_answers
    visit '/choose-a-certified-company'

    within('#matching-idps') do
      click_button 'Choose IDCorp'
    end

    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql true
    expect(page.get_rack_session_key('selected_idp')).to include('entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-one', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2))
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

  it 'displays mobile application installation message when user selects a reluctant yes for smart phone' do
    set_session_and_ab_session_cookies!
    reluctant_mob_installation_session
    visit '/choose-a-certified-company'
    expect(page).to have_content('have to download an app for')
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
