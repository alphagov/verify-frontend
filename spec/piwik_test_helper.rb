def stub_piwik_idp_registration(idp_name, selected_evidence: {}, recommended: false, idp_list: idp_name)
  recommended_str = recommended ? 'recommended' : 'not recommended'
  piwik_request = {
    '_cvar' => "{\"2\":[\"REGISTER_IDP\",\"#{idp_name}\"],\"5\":[\"IDP_SELECTION\",\"#{idp_list}\"]}",
    'action_name' => "#{idp_name} was chosen for registration (#{recommended_str}) with evidence #{selected_evidence.values.flatten.sort.join(', ')}",
  }
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))
end
