require 'feature_helper'

RSpec.describe 'When the user visits the confirm-your-identity page' do
  let(:cookie_hash) {
    { CookieNames::VERIFY_JOURNEY_HINT => 'encrypted_entity_id' }
  }
  before(:each) do
    stub_federation
    set_verify_front_journey_hint_cookie!
    stub_request(:get, api_uri('decrypt_cookie')).and_return(body: { 'entityId' => 'http://idcorp.com' }.to_json)
  end

  it 'displays the page in Welsh', pending: true do
    visit '/confirm-your-identity-cy'
    expect(page).to have_title 'Confirm your identity'
    expect(page).to have_css 'html[lang=cy]'
  end

  it 'displays the page in English' do
    visit '/confirm-your-identity'
    expect(page).to have_title 'Confirm your identity'
    expect(page).to have_css 'html[lang=en]'
  end

  it 'includes the appropriate feedback source' do
    visit '/confirm-your-identity'
    expect_feedback_source_to_be(page, 'CONFIRM_YOUR_IDENTITY')
  end

  it 'includes rp display name in text' do
    visit '/confirm-your-identity'
    expect(page).to have_text 'In order to Register for an identity profile'
  end

  it 'should include a link to sign-in in case listed idp is incorrect' do
    visit '/confirm-your-identity'
    expect(page).to have_link 'sign in with a different certified company', href: '/sign-in'
  end

  it 'should display only the idp that the user last verified with'do
    visit '/confirm-your-identity'
    expect(a_request(:get, api_uri('decrypt_cookie'))).to have_been_made.once
    expect(page).to have_button 'Select IDCorp'
    expect(page).to have_css('.company', count: 1)
  end
end
