require 'feature_helper'
require 'api_test_helper'

# HUB-71 Delete with test teardown
describe 'When a user in the no_questions test variant visits the choose a certified company page' do
  before(:each) do
    set_session_and_ab_session_cookies!('no_questions' => 'no_questions_variant')
    stub_api_idp_list_for_loa(default_idps)
  end

  context 'user has two docs and a mobile' do
    selected_answers = {
      device_type: { device_type_other: true },
      documents: { passport: true, driving_licence: true },
      phone: { mobile_phone: true }
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
      expect(page).not_to have_content 'Based on your answers'
      within('#matching-idps') do
        expect(page).to have_button('Choose IDCorp')
      end
    end

    it 'does show an IDP if the IDP profile has a subset of the user evidence, but not an exact match' do
      additional_documents = selected_answers[:documents].clone
      additional_documents[:driving_licence] = false
      page.set_rack_session(
        transaction_simple_id: 'test-rp',
        selected_answers: {
          selected_answers: additional_documents,
          phone: selected_answers[:phone],
          device_type: { device_type_other: true }
        }
      )

      visit '/choose-a-certified-company'

      within('#matching-idps') do
        expect(page).to have_button('Choose IDCorp')
      end
    end

    it 'redirects to the choose a certified company about page when selecting About link' do
      visit '/choose-a-certified-company'

      click_link 'About IDCorp'

      expect(page).to have_current_path(choose_a_certified_company_about_path('stub-idp-one'))
    end

    it 'displays the page in Welsh' do
      visit '/dewis-cwmni-ardystiedig'

      expect(page).to have_title t('hub.choose_a_certified_company.title', locale: :cy)
      expect(page).to have_css 'html[lang=cy]'
    end
  end

  it 'displays all IDPs even if no recommendations' do
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      selected_answers: {
          device_type: { device_type_other: true },
          documents: { passport: false }
      },
    )

    visit '/choose-a-certified-company'

    expect(page).to have_current_path(choose_a_certified_company_path)
    expect(page).not_to have_content t('hub.choose_a_certified_company.idp_count_html', company_count: 'no companies')
  end

  it 'shows all IDPs regardless of profiles' do
    stub_api_no_docs_idps
    page.set_rack_session(
      transaction_simple_id: 'test-rp',
      selected_answers: {
          device_type: { device_type_other: true },
          documents: { driving_licence: true },
          phone: { mobile_phone: true }
      },
    )

    visit '/choose-a-certified-company'

    expect(page).not_to have_content 'Based on your answers'

    within('#matching-idps') do
      expect(page).to have_button('Choose No Docs IDP')
      expect(page).to have_button('Choose IDCorp')
      expect(page).to have_button('Bob’s Identity Service')
      expect(page).to have_button('Choose Carol’s Secure ID')
    end
  end

  context 'IDP profile is in a demo period' do
    selected_answers = {
      device_type: { device_type_other: true },
      documents: { passport: true, driving_licence: true },
      phone: { mobile_phone: true }
    }

    it 'shows the IDP if the RP is not protected' do
      page.set_rack_session(
        transaction_simple_id: 'test-rp',
        selected_answers: selected_answers
      )

      visit '/choose-a-certified-company'

      within('#matching-idps') do
        expect(page).to have_button('Choose Bob’s Identity Service')
      end
    end

    it 'shows the IDP if the RP is protected' do
      page.set_rack_session(
        transaction_simple_id: 'test-rp-no-demo',
        selected_answers: selected_answers
      )

      visit '/choose-a-certified-company'

      within('#matching-idps') do
        expect(page).to have_button('Choose Bob’s Identity Service')
      end
    end
  end
end
