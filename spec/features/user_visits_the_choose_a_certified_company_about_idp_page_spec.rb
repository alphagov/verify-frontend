require 'feature_helper'

RSpec.feature 'user visits the choose a certified about idp page', type: :feature do
  let(:selected_evidence) { { documents: [:passport, :driving_licence], phone: [:mobile_phone] } }
  let(:given_a_session_with_selected_evidence) {
    page.set_rack_session(
      selected_idp: { entity_id: 'http://idcorp.com', simple_id: 'stub-idp-one' },
      selected_idp_was_recommended: true,
      selected_evidence: selected_evidence,
    )
  }
  scenario 'user visit about page for stub-idp-one and chooses it when its recommended' do
    entity_id = 'my-entity-id'
    stub_federation(entity_id)
    set_session_cookies!
    given_a_session_with_selected_evidence
    visit choose_a_certified_company_about_path('stub-idp-one')
    # expect(page).to have_content("Choose IDCorp")
    expect(page).to have_content("ID Corp is the premier identity proofing service around.")
    click_button "Choose IDCorp"
    expect(page).to have_current_path(redirect_to_idp_warning_path)
    expect(page.get_rack_session_key('selected_idp')).to eql('entity_id' => entity_id, 'simple_id' => 'stub-idp-one')
    expect(page.get_rack_session_key('selected_idp_was_recommended')).to eql true
  end

  scenario 'user visit about page for a non-existent idp' do
    stub_federation
    set_session_cookies!
    visit choose_a_certified_company_about_path('foobar')
    expect(page).to have_content(I18n.translate("errors.page_not_found.title"))
  end

  scenario 'user visit about page for a idp that is not viewable' do
    idps = [
        { 'simpleId' => 'foobar', 'entityId' => 'foobar' },
    ]
    body = { 'idps' => idps, 'transactionSimpleId' => 'test-rp', 'transactionEntityId' => 'some-entity-id' }
    stub_request(:get, api_uri('session/federation')).to_return(body: body.to_json)
    set_session_cookies!
    visit choose_a_certified_company_about_path('foobar')
    expect(page).to have_content(I18n.translate("errors.page_not_found.title"))
  end
end
