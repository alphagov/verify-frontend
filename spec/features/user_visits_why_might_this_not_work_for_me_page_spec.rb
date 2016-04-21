require 'feature_helper'

RSpec.describe 'When the user visits the why-might-this-not-work-for-me page' do
  before(:each) do
    set_session_cookies!
    stub_federation
  end

  it 'displays the page in Welsh' do
    visit '/why-might-this-not-work-for-me-cy'
    expect(page).to have_content("If you can't verify your identity using GOV.UK Verify, you can register for an identity profile here")
    expect(page).to have_css 'html[lang=cy]'
  end

  context 'with javascript enabled', js: true do
    it 'contains the choose certified company link with selected evidence params' do
      visit '/why-might-this-not-work-for-me?selected-evidence=smart_phone&selected-evidence=mobile_phone&selected-evidence=driving_licence&selected-evidence=passport'

      expect(page).to have_link "I’d like to try to verify my identity online", href: "/choose-a-certified-company?selected-evidence=smart_phone&selected-evidence=mobile_phone&selected-evidence=driving_licence&selected-evidence=passport"
    end
  end

  it 'includes other ways text' do
    visit '/why-might-this-not-work-for-me'

    expect(page).to have_content("If you can't verify your identity using GOV.UK Verify, you can register for an identity profile here")
    expect(page).to have_content('register for an identity profile')
    expect(page).to have_link 'here', href: 'http://www.example.com'
  end

  it 'includes the appropriate feedback source' do
    visit '/why-might-this-not-work-for-me'

    expect_feedback_source_to_be(page, 'WHY_THIS_MIGHT_NOT_WORK_FOR_ME_PAGE')
  end
end
