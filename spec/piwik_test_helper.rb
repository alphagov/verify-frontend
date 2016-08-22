def stub_piwik_idp_registration(idp_name, selected_answers: {}, recommended: false, idp_list: idp_name)
  recommended_str = recommended ? 'recommended' : 'not recommended'
  evidence = selected_answers.values.flat_map { |answer_set|
    answer_set.select { |_, v| v }.map { |item| item[0] }
  }.sort.join(', ')
  piwik_request = {
    '_cvar' => "{\"2\":[\"REGISTER_IDP\",\"#{idp_name}\"],\"5\":[\"IDP_SELECTION\",\"#{idp_list}\"]}",
    'action_name' => match(/#{idp_name} was chosen for registration \(#{recommended_str}\) \(index (\d+|-)\) with evidence #{evidence}/),
  }
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))
end

def stub_piwik_cycle_three(attribute_name)
  piwik_request = {
    '_cvar' => "{\"4\":[\"CYCLE_3\",\"#{attribute_name}\"]}",
    'action_name' => 'Cycle3 submitted',
  }
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))
end

def stub_piwik_cycle_three_cancel
  piwik_request = {
    'action_name' => 'Matching Outcome - Cancelled Cycle3'
  }
  stub_request(:get, INTERNAL_PIWIK.url).with(query: hash_including(piwik_request))
end
