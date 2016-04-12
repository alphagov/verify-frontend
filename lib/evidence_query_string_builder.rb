class EvidenceQueryStringBuilder
  def self.build(selected_evidence)
    selected_evidence = [:no_documents] if selected_evidence.empty?
    selected_evidence.collect { |evidence|
      if evidence == :landline
        evidence = "#{evidence}_phone"
      end
      "selected-evidence=#{evidence}"
    }.join('&')
  end
end
