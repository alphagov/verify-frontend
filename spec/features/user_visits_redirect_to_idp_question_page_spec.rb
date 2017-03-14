require 'feature_helper'
require 'api_test_helper'
require 'i18n'

RSpec.describe 'When the user visits the redirect to IDP question page' do
  let(:given_an_idp_with_interstitial_question_needed) {
    page.set_rack_session(
      selected_idp: { entity_id: 'stub-idp-one-doc-question', simple_id: 'stub-idp-one-doc-question' },
      selected_idp_was_recommended: true,
    )
  }
  before(:each) do
    set_session_and_session_cookies!
    given_an_idp_with_interstitial_question_needed
    visit '/redirect-to-idp-question'
  end

  it 'displays a question' do
    expect(page).to have_content('Verifying with FancyPants')
    expect(page).to have_content('I have a question')
  end

  context 'user fills more questions form', js: true do
    it 'should not say we cannot verify you when user selects yes' do
      choose 'interstitial_question_form_extra_info_true', allow_label_click: true
      expect(page).to_not have_content('may not be able to verify you')
    end

    it 'should say we cannot verify you when user selects no' do
      choose 'interstitial_question_form_extra_info_false', allow_label_click: true
      expect(page).to have_content('may not be able to verify you')
    end
  end
end
