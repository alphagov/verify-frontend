class EvidenceQueryStringParser
  include Evidence

  def self.parse(query_string)
    result = []
    query_string.split('&').each do |pair|
      key, value = pair.split('=')
      matching_attribute = ALL_ATTRIBUTES.detect { |attr| value == attr.to_s }
      if key == 'selected-evidence' && !matching_attribute.nil?
        result << matching_attribute
      end
    end
    result
  end
end
