require 'feature_helper'
require 'models/cookie_names'

RSpec.describe 'When the user visits the about page' do
  it 'includes the appropriate feedback source' do
    set_session_cookies!
    visit '/about'

    expect_feedback_source_to_be(page, 'ABOUT_PAGE')
  end
end
