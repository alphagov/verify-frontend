class EvidenceQueryStringParser
  def self.parse(query_string)
    result = []
    query_string.split('&').each do |pair|
      key, value = pair.split('=')
      if key == 'selected-evidence'
        result << value
      end
    end
    result
  end
end
