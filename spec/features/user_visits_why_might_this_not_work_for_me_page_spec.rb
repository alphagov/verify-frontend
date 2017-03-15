require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the why-might-this-not-work-for-me page' do
  before(:each) do
    set_session_and_session_cookies!
    page.set_rack_session(transaction_simple_id: 'test-rp')
  end

  it 'displays the page in Welsh' do
    visit '/pam-efallai-na-fydd-hyn-yn-gweithio-i-mi'
    expect(page).to have_content('If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile here')
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'includes other ways text' do
    visit '/why-might-this-not-work-for-me'

    expect(page).to have_content('If you can’t verify your identity using GOV.UK Verify, you can register for an identity profile here')
    expect(page).to have_content('register for an identity profile')
    expect(page).to have_link 'here', href: 'http://www.example.com'
  end

  it 'includes the appropriate feedback source' do
    visit '/why-might-this-not-work-for-me'

    expect_feedback_source_to_be(page, 'WHY_THIS_MIGHT_NOT_WORK_FOR_ME_PAGE')
  end

  it 'redirects to select documents page if user clicks try to verify link' do
    visit why_might_this_not_work_for_me_path

    click_link 'I’d like to try to verify my identity online'

    expect(page).to have_current_path(select_documents_path)
  end
end
