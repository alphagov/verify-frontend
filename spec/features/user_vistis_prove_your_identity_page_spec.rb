require 'feature_helper'
require 'api_test_helper'

RSpec.describe 'When the user visits the prove identity page' do
  before(:each) do
    stub_request(:get, "http://api.com:50240/config/transactions/enabled").to_return(
      status: 200,
      body: '[{"simpleId":"test-rp","serviceHomepage":"http://localhost:50130/test-rp","loaList":["LEVEL_2"]}]',
      headers: {}
    )
  end

  context 'will display the prove identity page' do
    before(:each) do
      set_session_and_session_cookies!
    end

    it 'in English' do
      visit '/prove-identity'
      expect(page).to have_content t('hub.prove_identity.heading')
      expect(page).to have_css 'html[lang=en]'
      expect_feedback_source_to_be(page, 'PROVE_IDENTITY_PAGE', '/prove-identity')
    end

    it 'in Welsh' do
      visit '/prove-identity-cy'
      expect(page).to have_content t('hub.prove_identity.heading')
      expect(page).to have_css 'html[lang=cy]'
    end
  end

  it 'will display the no cookies error when all cookies are missing' do
    allow(Rails.logger).to receive(:info)
    expect(Rails.logger).to receive(:info).with("No session cookies can be found").at_least(:once)
    visit "/prove-identity"
    expect(page).to have_content t('errors.no_cookies.enable_cookies')
    expect(page).to have_http_status :forbidden
    expect(page).to have_link 'feedback', href: '/feedback?feedback-source=COOKIE_NOT_FOUND_PAGE'
    expect(page).to have_link "register for an identity profile", href: "http://localhost:50130/test-rp"
  end
end
