class QueryStringParser
  def self.parse(query_string)
    result = {}
    query_string.split('&').each do |pair|
      key, value = pair.split('=')
      unless value.nil?
        result[key] ||= []
        result[key] << value
      end
    end
    result
  end
end
