require 'feature_helper'
require 'api_test_helper'
require 'i18n'

describe 'When the user visits the choose a certified company page' do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list(default_idps)
  end

  context 'user has two docs and a mobile' do
    selected_answers = {
        documents: { passport: true, driving_licence: true },
        phone: { mobile_phone: true, landline: true }
    }
    before :each do
      page.set_rack_session(
        transaction_simple_id: 'test-rp',
        selected_answers: selected_answers,
      )
    end

    it 'includes the appropriate feedback source' do
      visit '/choose-a-certified-company'

      expect_feedback_source_to_be(page, 'CHOOSE_A_CERTIFIED_COMPANY_PAGE', '/choose-a-certified-company')
    end

    it 'displays recommended IDPs' do
      visit '/choose-a-certified-company'

      expect(page).to have_current_path(choose_a_certified_company_path)
      expect(page).to have_content('Based on your answers, 3 companies can verify you now:')
      within('#matching-idps') do
        expect(page).to have_button('Choose IDCorp')
      end
    end

    it 'does not show an IDP if the IPD profile has a subset of the user evidence, but not an exact match' do
      additional_documents = selected_answers[:documents].clone
      additional_documents[:ni_driving_licence] = true
      page.set_rack_session(
        transaction_simple_id: 'test-rp',
        selected_answers: {
          selected_answers: additional_documents,
          phone: selected_answers[:phone]
        }
      )

      visit '/choose-a-certified-company'

      within('#matching-idps') do
        expect(page).to_not have_button('Choose IDCorp')
      end
    end

    it 'redirects to the choose a certified company about page when selecting About link' do
      visit '/choose-a-certified-company'

      click_link 'About IDCorp'

      expect(page).to have_current_path(choose_a_certified_company_about_path('stub-idp-one'))
    end

    it 'displays the page in Welsh' do
      visit '/dewis-cwmni-ardystiedig'

      expect(page).to have_title 'Dewiswch gwmni ardystiedig - GOV.UK Verify - GOV.UK'
      expect(page).to have_css 'html[lang=cy]'
    end
  end

  context 'user is from an LOA1 service' do
    it 'only LEVEL_1 recommended IDPs are displayed' do
      stub_api_idp_list(default_idps, 'LEVEL_1')

      page.set_rack_session(
        transaction_simple_id: 'test-rp',
        requested_loa: 'LEVEL_1',
        selected_answers: {
          documents: { passport: true, driving_licence: true },
          phone: { mobile_phone: true, landline: true }
        },
      )

      visit '/choose-a-certified-company'

      expect(page).to have_current_path(choose_a_certified_company_path)

      within('#matching-idps') do
        expect(page).to have_button('Choose LOA1 Corp')
      end
    end
  end

  it 'displays no IDPs if no recommendations' do
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      selected_answers: {
        documents: { passport: false }
      },
    )

    visit '/choose-a-certified-company'

    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page).to_not have_css('#non-matching-idps')
    expect(page).to have_content('Based on your answers, no companies can verify you now:')
  end

  it 'recommends some IDPs with a recommended profile, hides non-recommended profiles, and omits non-matching profiles' do
    stub_api_no_docs_idps
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      selected_answers: {
        documents: { driving_licence: true },
        phone: { mobile_phone: true, landline: true }
      },
    )

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

  context 'IDP profile is in a demo period' do
    selected_answers = {
      documents: { passport: true, driving_licence: true },
      phone: { mobile_phone: true }
    }

    it 'shows the IDP if the RP is not in the demo blacklist' do
      page.set_rack_session(
        transaction_simple_id: 'test-rp',
        selected_answers: selected_answers
      )

      visit '/choose-a-certified-company'

      within('#matching-idps') do
        expect(page).to have_button('Choose Demo IDP')
      end
    end

    it 'shows the IDP as unlikely if the RP is in the demo blacklist' do
      page.set_rack_session(
        transaction_simple_id: 'test-rp-no-demo',
        selected_answers: selected_answers
      )

      visit '/choose-a-certified-company'

      within('#matching-idps') do
        expect(page).to_not have_button('Choose Demo IDP')
      end

      within('#non-matching-idps') do
        expect(page).to have_button('Choose Demo IDP')
      end
    end
  end
end
