require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the will it work for me page' do
  before(:each) do
    set_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'includes the appropriate feedback source' do
    visit '/will-it-work-for-me'
    expect_feedback_source_to_be(page, 'WILL_IT_WORK_FOR_ME_PAGE')
  end

  it 'displays the page in Welsh' do
    visit '/ni-fydd-yn-gweithio-i-mi'
    expect(page).to have_title 'Allai i gael fy nilysu? - GOV.UK Verify - GOV.UK'
    expect(page).to have_css 'html[lang=cy]'
  end

  #JS has to be on, so it uses the real browser and query params can be inspected
  it 'redirects to the choose-a-company page when user is over 20 and is a uk resident', js: true do
    stub_federation
    visit '/will-it-work-for-me'

    choose 'will_it_work_for_me_form_above_age_threshold_true'
    choose 'will_it_work_for_me_form_resident_last_12_months_true'
    click_button 'Continue'

    expect(page).to have_current_path(choose_a_certified_company_path)
  end

  it 'redirects to the why-might-this-not-work-for-me page when user is over 20 and has moved to the uk in the last 12 months' do
    visit '/will-it-work-for-me'
    choose 'will_it_work_for_me_form_above_age_threshold_true'
    choose 'will_it_work_for_me_form_resident_last_12_months_false'
    choose 'will_it_work_for_me_form_not_resident_reason_movedrecently'

    click_button 'Continue'

    expect(page).to have_current_path(why_might_this_not_work_for_me_path)
  end

  it 'redirects to the why-might-this-not-work-for-me page when user is under 20' do
    visit '/will-it-work-for-me'
    choose 'will_it_work_for_me_form_above_age_threshold_false'
    choose 'will_it_work_for_me_form_resident_last_12_months_true'

    click_button 'Continue'

    expect(page).to have_current_path(why_might_this_not_work_for_me_path)
  end

  it 'redirects to the may-not-work-if-you-live-overseas page when user is over 20 and has address in the uk but not a resident' do
    visit '/will-it-work-for-me'
    choose 'will_it_work_for_me_form_above_age_threshold_false'
    choose 'will_it_work_for_me_form_resident_last_12_months_false'
    choose 'will_it_work_for_me_form_not_resident_reason_addressbutnotresident'

    click_button 'Continue'

    expect(page).to have_current_path(may_not_work_if_you_live_overseas_path)
  end

  it 'redirects to the will-not-work-without-uk-address page when user is over 20 and has no address in the uk' do
    visit '/will-it-work-for-me'
    choose 'will_it_work_for_me_form_above_age_threshold_false'
    choose 'will_it_work_for_me_form_resident_last_12_months_false'
    choose 'will_it_work_for_me_form_not_resident_reason_noaddress'

    click_button 'Continue'

    expect(page).to have_current_path(will_not_work_without_uk_address_path)
  end

  context 'shows a validation message when form is invalid' do
    it 'when js is off' do
      visit '/will-it-work-for-me'

      click_button 'Continue'

      expect(page).to have_current_path(will_it_work_for_me_path)
      expect(page).to have_content 'Please answer all the questions'
    end

    it 'when js is on', js: true do
      visit '/will-it-work-for-me'
      choose 'will_it_work_for_me_form_above_age_threshold_false'
      expect(page).to_not have_content(I18n.t('hub.will_it_work_for_me.question.not_resident_reason.title'))
      choose 'will_it_work_for_me_form_resident_last_12_months_false'
      expect(page).to have_content(I18n.t('hub.will_it_work_for_me.question.not_resident_reason.title'))
      click_button 'Continue'

      expect(page).to have_current_path(will_it_work_for_me_path)
      expect(page).to have_css '#validation-error-message-js', text: 'Please answer all the questions'
    end
  end

  it 'reports to Piwik when the form is valid' do
    stub_federation
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Can I be Verified Next' }

    visit '/will-it-work-for-me'
    choose 'will_it_work_for_me_form_above_age_threshold_true'
    choose 'will_it_work_for_me_form_resident_last_12_months_true'

    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to have_been_made.once
  end

  it 'does not report to Piwik when the form is invalid' do
    stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
    piwik_request = { 'action_name' => 'Can I be Verified Next' }

    visit '/will-it-work-for-me'
    click_button 'Continue'

    expect(a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))).to_not have_been_made
  end
end
