class EvidenceQueryStringParser
  include Evidence

  def self.parse(query_string)
    result = []
    query_string.split('&').each do |pair|
      key, value = pair.split('=')
      if key == 'selected-evidence' && ALL_ATTRIBUTES.any? { |attr| value == attr.to_s }
        result << value
      end
    end
    result
  end
end
