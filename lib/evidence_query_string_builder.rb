class EvidenceQueryStringBuilder
  def self.build(selected_evidence)
    selected_evidence = [:no_documents] if selected_evidence.empty?
    selected_evidence.collect { |evidence| "selected-evidence=#{evidence}" }.join('&')
  end
end
