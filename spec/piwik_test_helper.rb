def stub_piwik_request(extra_parameters = {}, extra_headers = {})
  piwik_request = {
    'rec' => '1',
    'apiv' => '1',
    'idsite' => INTERNAL_PIWIK.site_id.to_s,
    'cookie' => 'false',
  }
  piwik_headers = {
    'Connection' => 'Keep-Alive',
    'Host' => 'localhost:4242',
  }
  stub_request(:get, INTERNAL_PIWIK.url)
    .with(headers: piwik_headers.update(extra_headers), query: hash_including(piwik_request.update(extra_parameters)))
end

def stub_piwik_idp_registration(idp_name, selected_answers: {}, recommended: false, idp_list: idp_name)
  recommended_str = recommended ? 'recommended' : 'not recommended'
  evidence = selected_answers.values.flat_map { |answer_set|
    answer_set.select { |_, v| v }.map { |item| item[0] }
  }.sort.join(', ')
  piwik_request = {
    '_cvar' => "{\"5\":[\"IDP_SELECTION\",\"#{idp_list}\"]}",
    'action_name' => "#{idp_name} was chosen for registration (#{recommended_str}) with evidence #{evidence}",
  }
  stub_piwik_request(piwik_request)
end

def stub_piwik_cycle_three(attribute_name)
  piwik_request = {
    '_cvar' => "{\"4\":[\"CYCLE_3\",\"#{attribute_name}\"]}",
    'action_name' => 'Cycle3 submitted',
  }
  stub_piwik_request(piwik_request)
end

def stub_piwik_cycle_three_cancel
  piwik_request = {
    'action_name' => 'Matching Outcome - Cancelled Cycle3'
  }
  stub_piwik_request(piwik_request)
end

def stub_piwik_report_loa_requested(loa_requested)
  piwik_request = {
    '_cvar' => "{\"2\":[\"LOA_REQUESTED\",\"#{loa_requested}\"]}",
    'action_name' => "LOA Requested - #{loa_requested}"
  }
  stub_piwik_request(piwik_request)
end

def stub_piwik_report_loa_achieved(loa_achieved)
  piwik_request = {
    '_cvar' => "{\"3\":[\"LOA_ACHIEVED\",\"#{loa_achieved}\"]}",
    'action_name' => "LOA Achieved - #{loa_achieved}"
  }
  stub_piwik_request(piwik_request)
end

def stub_piwik_request_with_rp(extra_parameters = {})
  cvar = {
    '_cvar' => "{\"1\":[\"RP\",\"analytics description for test-rp\"]}"
  }
  stub_piwik_request(extra_parameters.merge(cvar))
end

def stub_piwik_report_number_of_recommended_ipds(number_of_recommended_idps)
  piwik_request = {
      e_c: 'Engagement',
      action_name: 'trackEvent',
      e_a: 'IDPs Recommended',
      e_v: number_of_recommended_idps.to_s
  }
  stub_piwik_request(piwik_request)
end

def a_request_to_piwik
  a_request(:get, INTERNAL_PIWIK.url).with(query: hash_including({}))
end
