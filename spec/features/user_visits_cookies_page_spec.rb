require 'feature_helper'

RSpec.describe 'When the user visits the cookies page' do
  it 'displays the page in English' do
    visit '/cookies'
    expect(page).to have_content("GOV.UK puts small files (known as ‘cookies’) onto your computer to collect information about how you browse the site.")
    expect(page).to have_content('x-govuk-secure-cookie')
    expect(page).to have_content('x_govuk_session_cookie')
    expect(page).to have_content('_verify-frontend_session')
    expect(page).to have_content('session_start_time')
    expect(page).to have_content('seen_cookie_message')
    expect(page).to have_content('_pk_id')
    expect(page).to have_content('_pk_ses')
    expect(page).to have_content('_pk_ref')
    expect(page).to have_content('verify-journey-hint')
    expect(page).to have_content('PIWIK_VISITOR_ID')
    expect(page).to have_content('ab_test')
  end

  it 'displays the page in Welsh' do
    visit '/cookies-cy'
    expect(page).to have_content("Mae GOV.UK Verify wrthi’n cael ei gyfieithu i’r Gymraeg.")
  end

  it 'includes the appropriate feedback source' do
    visit '/cookies'
    expect_feedback_source_to_be(page, 'COOKIES_INFO_PAGE')
  end
end
