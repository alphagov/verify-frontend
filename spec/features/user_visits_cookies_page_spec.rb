require 'feature_helper'

RSpec.describe 'When the user visits the cookies page' do
  it 'displays the page in English' do
    visit '/cookies'
    expect(page).to have_content('GOV.UK Verify puts small files (known as \'cookies\') onto your computer.')
    page_should_have_cookie_descriptions
  end

  it 'displays the page in Welsh' do
    visit '/cwcis'
    expect(page).to have_content('Mae GOV.UK Verify yn gosod feiliau bychan (a elwir yn \'cwcis\') ar eich cyfrifiadur.')
  end

  def page_should_have_cookie_descriptions
    expect(page).to have_content('x_govuk_session_cookie')
    expect(page).to have_content('_verify-frontend_session')
    expect(page).to have_content('seen_cookie_message')
    expect(page).to have_content('_pk_id')
    expect(page).to have_content('_pk_ses')
    expect(page).to have_content('_pk_ref')
    expect(page).to have_content('verify-front-journey-hint')
    expect(page).to have_content('PIWIK_USER_ID')
    expect(page).to have_content('ab_test')
  end

  it 'includes the appropriate feedback source' do
    visit '/cookies'
    expect_feedback_source_to_be(page, 'COOKIES_INFO_PAGE', '/cookies')
  end

  it 'will allow robots to index' do
    visit '/cookies'
    expect(page).to_not have_css('meta[name="robots"]', visible: false)
  end
end
