require 'feature_helper'
require 'cookie_names'
require 'api_test_helper'

RSpec.describe 'When the user visits the about choosing a company page' do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_loa
  end

  it 'will include the appropriate feedback source' do
    visit '/about-choosing-a-company'

    expect_feedback_source_to_be(page, 'ABOUT_CHOOSING_A_COMPANY_PAGE', '/about-choosing-a-company')
  end

  it 'will display content in Welsh' do
    visit '/am-ddewis-cwmni'

    expect(page).to have_content 'Dod o hyd i’r cwmni iawn i’ch dilysu chi'
  end

  it 'will take user to will-it-work-for-me page when user clicks "Continue"' do
    visit '/about-choosing-a-company'

    click_link 'Continue'
    expect(page).to have_current_path(will_it_work_for_me_path)
  end

  # HUB-71 Delete with test teardown
  context 'in the no questions test variant' do
    before(:each) do
      set_session_and_ab_session_cookies!('no_questions' => 'no_questions_variant')
    end

    it 'will display variant content in Welsh' do
      visit '/am-ddewis-cwmni'

      expect(page).to have_content 'Dod o hyd i’r cwmni iawn i’ch dilysu chi'
      expect(page).to have_content 'Mae cwmnïau ardystiedig wedi adeiladu systemau newydd'
      expect(page).not_to have_content 'Felly byddwn nawr yn gofyn rhai cwestiynau i chi wirio pa gwmnïau all eich dilysu.'
    end

    it 'will display the variant content' do
      visit '/about-choosing-a-company'

      expect(page).to have_content 'Finding the right company to verify you'
      expect(page).to have_content 'Certified companies have built new, secure systems to verify identities.'
      expect(page).not_to have_content 'So we’ll now ask you some questions to check which companies can verify you.'
    end

    it 'will take user to choose-a-certified-company page when user clicks "Continue"' do
      visit '/about-choosing-a-company'

      click_link 'Continue'
      expect(page).to have_current_path(choose_a_certified_company_path)
    end
  end
end
