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

  it 'redirects to the why-might-this-not-work-for-me page when user is over 20 and has moved to the uk in the last 12 months' do
    visit '/will-it-work-for-me'
    choose 'will_it_work_for_me_form_above_age_threshold_true'
    choose 'will_it_work_for_me_form_resident_last_12_months_false'
    choose 'will_it_work_for_me_form_not_resident_reason_movedrecently'

    click_button 'Continue'

    expect(page).to have_current_path(why_might_this_not_work_for_me_path)
  end

  it 'redirects to the may-not-work-if-you-live-overseas page when user is over 20 and has address in the uk but not a resident' do
    visit '/will-it-work-for-me'
    choose 'will_it_work_for_me_form_above_age_threshold_true'
    choose 'will_it_work_for_me_form_resident_last_12_months_false'
    choose 'will_it_work_for_me_form_not_resident_reason_addressbutnotresident'

    click_button 'Continue'

    expect(page).to have_current_path(may_not_work_if_you_live_overseas_path)
  end

  it 'redirects to the will-not-work-without-uk-address page when user is over 20 and has no address in the uk' do
    visit '/will-it-work-for-me'
    choose 'will_it_work_for_me_form_above_age_threshold_true'
    choose 'will_it_work_for_me_form_resident_last_12_months_false'
    choose 'will_it_work_for_me_form_not_resident_reason_noaddress'

    click_button 'Continue'

    expect(page).to have_current_path(will_not_work_without_uk_address_path)
  end
end
