require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the select documents page' do
  before(:each) do
    set_session_cookies!
  end

  it 'displays the page in Welsh' do
    visit '/dewiswch-ddogfennau'
    expect(page).to have_title 'Dewiswch yr holl ddogfennau sydd gennych - GOV.UK Verify - GOV.UK'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'includes the appropriate feedback source' do
    visit '/select-documents'

    expect_feedback_source_to_be(page, 'SELECT_DOCUMENTS_PAGE')
  end
end
