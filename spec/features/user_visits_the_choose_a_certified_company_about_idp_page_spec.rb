require 'feature_helper'
require 'api_test_helper'

RSpec.feature 'user visits the choose a certified company about idp page', type: :feature do
  let(:selected_answers) { { documents: { passport: true, driving_licence: true }, phone: { mobile_phone: true } } }
  let(:given_a_session_with_selected_answers) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      selected_answers: selected_answers,
    )
  }
  scenario 'user chooses a recommended idp' do
    entity_id = 'my-entity-id'
    stub_federation(entity_id)
    set_session_and_session_cookies!
    given_a_session_with_selected_answers
    visit choose_a_certified_company_about_path('stub-idp-one')
    expect(page).to have_content("ID Corp is the premier identity proofing service around.")
    click_button "Choose IDCorp"
    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => entity_id, 'simple_id' => 'stub-idp-one')
    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql true
  end

  scenario 'for a non-existent idp' do
    stub_federation
    set_session_and_session_cookies!
    visit choose_a_certified_company_about_path('foobar')
    expect(page).to have_content(I18n.translate("errors.page_not_found.title"))
  end

  scenario 'for an idp that is not viewable' do
    idps = [
        { 'simpleId' => 'foobar', 'entityId' => 'foobar' },
    ]
    body = { 'idps' => idps, 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-entity-id' }
    stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
    set_session_and_session_cookies!
    visit choose_a_certified_company_about_path('foobar')
    expect(page).to have_content(I18n.translate("errors.page_not_found.title"))
  end

  scenario 'user clicks back link' do
    entity_id = 'my-entity-id'
    stub_federation(entity_id)
    set_session_and_session_cookies!
    given_a_session_with_selected_answers
    visit choose_a_certified_company_about_path('stub-idp-one')
    click_link 'Back'
    expect(page).to have_current_path(choose_a_certified_company_path)
  end
end
