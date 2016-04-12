require 'feature_helper'

RSpec.describe 'When the user visits the will it work for me page' do
  before(:each) do
    set_session_cookies!
  end

  it 'includes the appropriate feedback source' do
    visit '/will-it-work-for-me'
    expect_feedback_source_to_be(page, 'WILL_IT_WORK_FOR_ME_PAGE')
  end

  it 'redirects to the choose-a-company page when user is over 20 and is a uk resident' do
    stub_federation
    visit '/will-it-work-for-me'

    choose 'will_it_work_for_me_form_above_age_threshold_true'
    choose 'will_it_work_for_me_form_resident_last_12_months_true'
    click_button 'Continue'

    expect(page).to have_current_path(choose_a_certified_company_path, only_path: true)
  end
end
