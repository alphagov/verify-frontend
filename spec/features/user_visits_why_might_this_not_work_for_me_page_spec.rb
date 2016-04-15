require 'feature_helper'

RSpec.describe 'When the user visits the why-might-this-not-work-for-me page' do
  before(:each) do
    set_session_cookies!
  end

  context 'with javascript enabled', js: true do
    it 'contains the choose certified company link with selected evidence params' do
      visit '/why-might-this-not-work-for-me?selected-evidence=smart_phone&selected-evidence=mobile_phone&selected-evidence=driving_licence&selected-evidence=passport'

      expect(page).to have_link "I’d like to try to verify my identity online", href: "/choose-a-certified-company?selected-evidence=smart_phone&selected-evidence=mobile_phone&selected-evidence=driving_licence&selected-evidence=passport"
    end
  end

  it 'includes other ways text' do
  end

  it 'includes the appropriate feedback source' do
  end
end
