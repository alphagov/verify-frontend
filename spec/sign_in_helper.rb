def when_i_select_an_idp idp_display_name
  # There may be multiple identical buttons due to the journey hint
  # so we can't use 'click_button'
  all(:button, idp_display_name)[0].click
end

def then_im_at_the_idp(ab_value: nil, journey_type: "sign-in")
  expect(page).to have_current_path(location)
  expect(page).to have_content("SAML Request is 'a-saml-request'")
  expect(page).to have_content("relay state is 'a-relay-state'")
  expect(page).to have_content("registration is 'false'")
  expect(cookie_value("verify-front-journey-hint")).to_not be_nil

  expect(a_request(:post, policy_api_uri(select_idp_endpoint(default_session_id)))
             .with(body: { PolicyEndpoints::PARAM_SELECTED_ENTITY_ID => idp_entity_id,
                           PolicyEndpoints::PARAM_PRINCIPAL_IP => originating_ip,
                           PolicyEndpoints::PARAM_REGISTRATION => false,
                           PolicyEndpoints::PARAM_REQUESTED_LOA => "LEVEL_2",
                           PolicyEndpoints::PARAM_PERSISTENT_SESSION_ID => instance_of(String), # no longer comes from matomo
                           PolicyEndpoints::PARAM_JOURNEY_TYPE => journey_type,
                           PolicyEndpoints::PARAM_VARIANT => ab_value })).to have_been_made.once
  expect(a_request(:get, saml_proxy_api_uri(authn_request_endpoint(default_session_id)))
             .with(headers: { "X_FORWARDED_FOR" => originating_ip })).to have_been_made.once
end
