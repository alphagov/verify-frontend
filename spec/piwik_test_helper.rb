def stub_piwik_request(extra_parameters = {},
                       extra_headers = {},
                       loa = "LEVEL_2",
                       extra_custom_variables = [],
                       transaction_analytics_description = "analytics description for test-rp")
  piwik_request = {
    rec: "1",
    apiv: "1",
    idsite: INTERNAL_PIWIK.site_id.to_s,
    cookie: "false",
    _cvar: create_custom_variable_param(loa, extra_custom_variables, transaction_analytics_description),
  }

  piwik_headers = {
    Connection: "Keep-Alive",
    Host: "localhost:4242",
  }

  stub_request(:get, INTERNAL_PIWIK.url)
    .with(headers: piwik_headers.update(extra_headers), query: hash_including(piwik_request.update(extra_parameters)))
end

def stub_piwik_request_no_session(extra_parameters = {}, extra_headers = {}, extra_custom_variables = [])
  piwik_request = {
    rec: "1",
    apiv: "1",
    idsite: INTERNAL_PIWIK.site_id.to_s,
    cookie: "false",
    _cvar: create_extra_custom_variables_only(extra_custom_variables),
  }

  piwik_headers = {
    Connection: "Keep-Alive",
    Host: "localhost:4242",
    'User-Agent': "Rails Testing",
  }

  stub_request(:get, INTERNAL_PIWIK.url)
    .with(headers: piwik_headers.update(extra_headers), query: hash_including(piwik_request.update(extra_parameters)))
end

def stub_piwik_request_no_session_no_cvar(extra_parameters = {}, extra_headers = {})
  piwik_request = {
    rec: "1",
    apiv: "1",
    idsite: INTERNAL_PIWIK.site_id.to_s,
    cookie: "false",
  }

  piwik_headers = {
    Connection: "Keep-Alive",
    Host: "localhost:4242",
    'User-Agent': "Rails Testing",
  }

  stub_request(:get, INTERNAL_PIWIK.url)
    .with(headers: piwik_headers.update(extra_headers), query: hash_including(piwik_request.update(extra_parameters)))
end

def create_extra_custom_variables_only(extra_custom_variables)
  "{" + extra_custom_variables.join(",") + "}"
end

def create_custom_variable_param(loa, extra_custom_variables, transaction_analytics_description)
  rp_custom_variable = %["1":["RP","#{transaction_analytics_description}"]]
  loa_custom_variable = %["2":["LOA_REQUESTED","#{loa}"]]

  param = "{#{rp_custom_variable},#{loa_custom_variable}"

  extra_custom_variables.each do |custom_variable|
    param += ",#{custom_variable}"
  end

  param += "}"
  param
end

def stub_piwik_report_idp_resume_selection(idp_display_name, loa = "LEVEL_2")
  piwik_request = {
    action_name: "Resume - #{idp_display_name}",
  }

  stub_piwik_request(piwik_request, {}, loa)
end

def stub_piwik_report_single_idp_selection(idp_display_name, loa = "LEVEL_2")
  piwik_request = {
    action_name: "Single IDP selected - #{idp_display_name}",
  }

  stub_piwik_request(piwik_request, {}, loa)
end

def stub_piwik_report_sign_in_idp_selection(idp_display_name, loa = "LEVEL_2", hint: nil)
  piwik_request = {
    action_name: "Sign In - #{idp_display_name}#{" - Hint #{hint == :followed ? 'Followed' : 'Ignored'}" if hint}",
  }

  stub_piwik_request(piwik_request, {}, loa)
end

def stub_piwik_report_user_idp_attempt(idp_name, transaction_id, journey_type = JourneyType::SIGN_IN, attempt_number: 1, loa: "LEVEL_2", hint_present: false, hint_followed: false)
  piwik_request = {
    action_name: "ATTEMPT_#{attempt_number} | #{journey_type.downcase} | #{transaction_id} | #{idp_name} | #{'not ' unless hint_present}present | #{'not ' unless hint_followed}followed |",
  }

  stub_piwik_request(piwik_request, {}, loa)
end

def stub_piwik_idp_registration(idp_name, loa = "LEVEL_2", idp_list: idp_name)
  idp_selection_custom_variable = %["5":["IDP_SELECTION","#{idp_list}"]]
  piwik_request = {
    action_name: "#{idp_name} was chosen for registration",
  }

  stub_piwik_request(piwik_request, {}, loa, [idp_selection_custom_variable])
end

def stub_piwik_cycle_three(attribute_name)
  cycle_three_custom_variable = %["4":["CYCLE_3","#{attribute_name}"]]
  piwik_request = { action_name: "Cycle3 submitted" }
  stub_piwik_request(piwik_request, {}, "LEVEL_2", [cycle_three_custom_variable])
end

def stub_piwik_cycle_three_cancel
  piwik_request = { action_name: "Matching Outcome - Cancelled Cycle3" }
  stub_piwik_request(piwik_request)
end

def stub_piwik_request_with_rp_and_loa(extra_parameters = {}, loa = "LEVEL_2")
  stub_piwik_request(extra_parameters, {}, loa)
end

def stub_piwik_report_number_of_recommended_idps(number_of_recommended_idps, loa, transaction_analytics_description)
  piwik_request = {
    e_c: "Engagement",
    action_name: "trackEvent",
    e_n: "IDPs Recommended",
    e_a: number_of_recommended_idps.to_s,
  }

  stub_piwik_request(piwik_request, {}, loa, [], transaction_analytics_description)
end

def stub_piwik_report_journey_hint_present(hint_present)
  piwik_request = {
    e_c: "Engagement",
    action_name: "trackEvent",
    e_n: "Journey hint present",
    e_a: hint_present,
  }

  stub_piwik_request_no_session_no_cvar(piwik_request)
end

def stub_piwik_report_single_idp_success(service_id, uuid)
  piwik_request = {
    e_c: "Single IDP",
    action_name: "trackEvent",
    e_n: "redirected to IDP",
    e_a: "Service: #{service_id}, UUID: #{uuid}",
  }

  stub_piwik_request(piwik_request, 'User-Agent': "Rails Testing")
end

def stub_piwik_report_single_idp_invalid_cookie
  piwik_request = {
    e_c: "Single IDP",
    action_name: "trackEvent",
    e_n: "invalid cookie",
    e_a: "Missing or malformed cookie",
  }

  stub_piwik_request(piwik_request, 'User-Agent': "Rails Testing")
end

def stub_piwik_report_single_idp_service_mismatch(expected_service, actual_service, uuid)
  piwik_request = {
    e_c: "Single IDP",
    action_name: "trackEvent",
    e_n: "change of service",
    e_a: "Expected service: #{expected_service}, Actual service: #{actual_service}, UUID: #{uuid}",
  }

  stub_piwik_request(piwik_request, 'User-Agent': "Rails Testing")
end

def stub_piwik_journey_type_request(journey_type, action_name, loa = "LEVEL_2")
  journey_custom_variable = %["3":["JOURNEY_TYPE","#{journey_type}"]]
  piwik_request = { action_name: action_name }

  stub_piwik_request(piwik_request, {}, loa, [journey_custom_variable])
end

def stub_piwik_journey_type_request_no_session(journey_type, action_name)
  journey_custom_variable = %["3":["JOURNEY_TYPE","#{journey_type}"]]
  piwik_request = { action_name: action_name }

  stub_piwik_request_no_session(piwik_request, {}, [journey_custom_variable])
end
