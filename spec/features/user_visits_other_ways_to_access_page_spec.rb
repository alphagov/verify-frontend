require 'feature_helper'

RSpec.describe 'When the user visits the other ways to access page' do
  before(:each) do
    set_session_and_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'includes expected content' do
    visit '/other-ways-to-access-service'

    expect(page).to have_title t('hub.other_ways_title')
    expect(page).to have_content t('hub.other_ways_heading', other_ways_description: t('rps.test-rp.name'))
    expect(page.body).to include t('rps.test-rp.other_ways_text')
    expect(page).to have_link 'here', href: 'http://www.example.com'
    expect_feedback_source_to_be(page, 'OTHER_WAYS_PAGE', '/other-ways-to-access-service')
  end

  it 'includes expected content in welsh' do
    visit "/ffyrdd-eraill-i-gael-mynediad-i'r-gwasanaeth"

    expect(page).to have_title t('hub.other_ways_title', locale: :cy)
    expect(page).to have_content t('hub.other_ways_heading', locale: :cy, other_ways_description: t('rps.test-rp.name'))

    expect(page.body).to include t('rps.test-rp.other_ways_text')
  end
end
