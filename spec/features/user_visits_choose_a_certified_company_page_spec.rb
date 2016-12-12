# coding: utf-8
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

  let(:abtest_answers) {
    {
      documents: { ni_driving_licence: true },
      phone: { mobile_phone: true }
    }
  }

  let(:given_a_session_with_abtest_answers) {
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      selected_answers: abtest_answers,
    )
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

  context 'IDP Ranking AB testing' do
    let(:given_an_abtest_with_control_group) {
      set_cookies!(CookieNames::AB_TEST => CGI.escape({ 'idp_ranking' => 'idp_ranking_control' }.to_json))
    }
    let(:given_an_abtest_with_by_completion_group) {
      set_cookies!(CookieNames::AB_TEST => CGI.escape({ 'idp_ranking' => 'idp_ranking_by_completion' }.to_json))
    }

    it 'will show IDPs in ranking order on by_completion path' do
      given_a_session_with_abtest_answers
      given_an_abtest_with_by_completion_group

      visit choose_a_certified_company_path

      within('#matching-idps') do
        ranked_idps = all(:css, '.idp-option/button').map(&:value)
        expect(ranked_idps).to eq(["Bob’s Identity Service", "Carol’s Secure ID", "IDCorp"])
      end
    end

    it 'will report control group to piwik if theres a ranking' do
      given_a_session_with_abtest_answers
      given_an_abtest_with_control_group

      visit choose_a_certified_company_path

      piwik_request = {
        '_cvar' => '{"6":["AB_TEST","idp_ranking_control"]}'
      }
      expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
    end


    it 'will not report to piwik if theres is no ranking' do
      given_a_session_with_selected_answers
      given_an_abtest_with_control_group

      visit choose_a_certified_company_path

      piwik_request = {
          '_cvar' => '{"6":["AB_TEST","idp_ranking_control"]}'
      }
      expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_not_been_made
    end

    it 'will report by completion group to piwik if theres a ranking' do
      given_a_session_with_abtest_answers
      given_an_abtest_with_by_completion_group

      visit choose_a_certified_company_path

      piwik_request = {
        '_cvar' => '{"6":["AB_TEST","idp_ranking_by_completion"]}'
      }
      expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
    end
  end
end
