require 'feature_helper'

RSpec.describe 'When the user visits the accessibility page' do
  it 'displays the page in English' do
    visit '/accessibility'
    expect(page).to have_title t('hub.accessibility.title')
    expect(page).to have_content 'We want as many people as possible to be able to use this website'
    expect(page).to have_content 'Reporting accessibility problems with this website'
  end

  it 'includes the appropriate feedback source' do
    visit '/accessibility'
    expect_feedback_source_to_be(page, 'ACCESSIBILITY_PAGE', '/accessibility')
  end
end
