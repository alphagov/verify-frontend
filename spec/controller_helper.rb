def set_session_and_cookies_with_loa(loa_requested, identity_providers = [{ 'simple_id' => 'stub-idp-one', 'entity_id' => 'http://idcorp.com' }])
  session[:requested_loa] = loa_requested
  session[:verify_session_id] = 'my-session-id-cookie'
  session[:transaction_simple_id] = 'test-rp'
  session[:identity_providers] = identity_providers
  session[:start_time] = DateTime.now.to_i * 1000
  cookies[CookieNames::SESSION_COOKIE_NAME] = 'my-session-cookie'
  cookies[CookieNames::SESSION_ID_COOKIE_NAME] = 'my-session-id-cookie'
end

def stub_session
  session[:selected_idp] = { 'entity_id' => 'http://idcorp.com', 'simple_id' => 'stub-idp-loa1', 'levels_of_assurance' => %w(LEVEL_1 LEVEL_2) }
  session[:selected_idp_was_recommended] = true
  session[:transaction_simple_id] = 'test-rp'
end

def create_session_cookie(key, value)
  session[key.to_sym] = value
end

def stub_identity_provider_display_decorator(identity_provider_display_decorator, simple_id, entity_id, levels_of_assurance)
  loa_identity_provider = IdentityProvider.new('simple_id' => simple_id,
                                               'entity_id' => entity_id,
                                               'levels_of_assurance' => levels_of_assurance)

  viewable_identity_provider_stub = ViewableIdentityProvider.new(loa_identity_provider, display_data, 'idp-logos/barclays.png', 'idp-logos-white/barclays.png')

  expect(identity_provider_display_decorator).to receive(:decorate) { |identity_provider|
    expect(identity_provider).to have_attributes(simple_id: simple_id,
                                                 entity_id: entity_id,
                                                 levels_of_assurance: levels_of_assurance)
  }.and_return(viewable_identity_provider_stub)
  expect(viewable_identity_provider_stub).to receive(:display_name).and_return('idp-display-name')

  identity_provider_display_decorator
end

def stub_rp_display_repository(transaction_simple_data)
  current_transaction = ""

  def current_transaction.name
    "Test-RP"
  end
  { transaction_simple_data => current_transaction }
end

ViewableIdentityProvider = Struct.new(
  :identity_provider,
  :display_data,
  :logo_path,
  :white_logo_path
) do
  delegate :entity_id, to: :identity_provider
  delegate :simple_id, to: :identity_provider
  delegate :model_name, to: :identity_provider
  delegate :to_key, to: :identity_provider
  delegate :display_name, :about_content, :requirements, :special_no_docs_instructions, :no_docs_requirement, :contact_details, :interstitial_question, :tagline, to: :display_data
end
