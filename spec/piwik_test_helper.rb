def stub_piwik_idp_registration(idp_name, selected_answers: {}, recommended: false, idp_list: idp_name)
  recommended_str = recommended ? 'recommended' : 'not recommended'
  evidence = selected_answers.values.flat_map { |answer_set|
    answer_set.select { |_, v| v }.map { |item| item[0] }
  }.sort.join(', ')
  piwik_request = {
    '_cvar' => "{\"2\":[\"REGISTER_IDP\",\"#{idp_name}\"],\"5\":[\"IDP_SELECTION\",\"#{idp_list}\"]}",

    'action_name' => "#{idp_name} was chosen for registration (#{recommended_str}) with evidence #{evidence}",
  }
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))
end
