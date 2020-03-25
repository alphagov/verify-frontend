require 'feature_helper'
require 'cookie_names'
require 'piwik_test_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the what happens next page' do
  before(:each) do
    set_session_and_session_cookies!
    stub_api_idp_list_for_registration
    set_selected_idp_in_session(entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one')
  end

  context 'session cookie contains transaction id' do
    it "will display the page and report the user's selection to piwik" do
      visit '/what-happens-next'

      expect(page).to have_content(t('hub.what_happens_next.heading'))
      expect_feedback_source_to_be(page, 'WHAT_HAPPENS_NEXT_PAGE', '/what-happens-next')
      expect(page).to have_link('Continue', href: '/redirect-to-idp-warning')
    end

    it 'will display the what_happens_next page in Welsh' do
      visit '/what-happens-next-cy'
      expect(page).to have_content(t('hub.what_happens_next.heading'))
      expect(page).to have_css 'html[lang=cy]'
    end
  end
end
