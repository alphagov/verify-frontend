require 'feature_helper'

RSpec.describe 'When the user visits the may-not-work-if-you-live-overseas page' do
  before(:each) do
    set_session_cookies!
    stub_federation
  end

  context 'with javascript enabled', js: true do
    it 'contains the choose certified company link with selected evidence params' do
      visit '/may-not-work-if-you-live-overseas?selected-evidence=smart_phone&selected-evidence=mobile_phone&selected-evidence=driving_licence&selected-evidence=passport'

      puts page.body
      expect(page).to have_link "I’d like to try to verify my identity online", href: "/choose-a-certified-company?selected-evidence=smart_phone&selected-evidence=mobile_phone&selected-evidence=driving_licence&selected-evidence=passport"
    end
  end
end
