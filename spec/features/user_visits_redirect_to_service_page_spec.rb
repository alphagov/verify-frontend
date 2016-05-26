require 'feature_helper'
require 'api_test_helper'

def hidden_field_value(id)
  page.find("##{id}", visible: false).value
end

RSpec.describe 'When the user visits the redirect to service page' do
  before(:each) do
    set_session_cookies!
  end

  context 'without javascript' do
    it 'will show a continue button' do
      api_request = stub_response_for_rp

      visit redirect_signing_in_path
      expect(page).to have_title('Please wait. Signing you in')

      expect(hidden_field_value('SAMLResponse')).to eql('a saml message')
      expect(hidden_field_value('RelayState')).to eql('a relay state')

      click_button 'Continue'
      expect(page).to have_current_path('/test-rp')
      expect(api_request).to have_been_made.once
    end
  end
end
