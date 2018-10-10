require 'feature_helper'
require 'api_test_helper'
require 'piwik_test_helper'

RSpec.describe 'When the user is sent to the paused registration page using a link emailed from IDP' do
  let(:idp_display_name) { 'IDCorp' }
  let(:idp_entity_id) { 'http://idcorp.com' }
  let(:idp_simple_id) { 'stub-idp-one' }

  before(:each) do
    stub_api_idp_list_for_sign_in
    stub_translations
  end

  context 'and the IDP specified in the URL is valid' do
    it 'renders page with a list of available services' do
      stub_transaction_details
      set_session_and_session_cookies!
      visit '/paused/stub-idp-one'

      expect(page).to have_content(t('hub.paused_registration.from_resume_link.heading', idp_name: idp_display_name))
    end
  end
end
