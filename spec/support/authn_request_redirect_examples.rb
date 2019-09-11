shared_examples 'idp_authn_request_redirects' do |additional_parameters = {}|
  it 'will redirect the user to resume registration page if cookie state is PENDING' do
    front_journey_hint_cookie = {
      STATE: {
        IDP: valid_idp,
        RP: valid_rp,
        STATUS: 'PENDING'
      }
    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }.merge(additional_parameters)
    expect(response).to redirect_to resume_registration_path(additional_parameters)
  end

  it 'will redirect the user to confirm your identity page if this is a non-repudiation even if cookie state is PENDING' do
    front_journey_hint_cookie = {
      STATE: {
        IDP: valid_idp,
        RP: valid_rp,
        STATUS: 'PENDING'
      }
    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state', 'journey_hint' => 'submission_confirmation' }.merge(additional_parameters)
    expect(response).to redirect_to confirm_your_identity_path(additional_parameters)
  end

  it 'will redirect the user to default start page if cookie state is not PENDING' do
    front_journey_hint_cookie = {
      STATE: {
        IDP: valid_idp,
        RP: valid_rp,
        STATUS: 'SUCCESS'
      }
    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }.merge(additional_parameters)
    expect(response).to redirect_to start_path(additional_parameters)
  end

  it 'will redirect the user to default start page if cookie state is missing' do
    front_journey_hint_cookie = {

    }

    cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] = front_journey_hint_cookie.to_json
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }.merge(additional_parameters)
    expect(response).to redirect_to start_path(additional_parameters)
  end

  it 'will redirect the user to default start page if cookie is missing' do
    post :rp_request, params: { 'SAMLRequest' => 'my-saml-request', 'RelayState' => 'my-relay-state' }.merge(additional_parameters)
    expect(response).to redirect_to start_path(additional_parameters)
  end
end
