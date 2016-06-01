def stub_piwik_idp_selection_list(idp_name)
  piwik_request = {
    '_cvar' => "{\"5\":[\"IDP_SELECTION\",\"#{idp_name}\"]}",
    'action_name' => 'IDP selection'
  }
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))
end

def stub_piwik_idp_registration(idp_name, selected_evidence, recommended: true)
  recommended_str = recommended ? 'recommended' : 'not recommended'
  piwik_request = {
    '_cvar' => "{\"2\":[\"REGISTER_IDP\",\"#{idp_name}\"]}",
    'action_name' => "IDCorp was chosen for registration (#{recommended_str}) with evidence #{selected_evidence.values.flatten.sort.join(', ')}",
  }
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))
end
