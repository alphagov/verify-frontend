class QueryStringParser
  def self.parse(query_string)
    result = {}
    URI.decode_www_form(query_string).each do |pair|
      key, value = pair
      unless value.nil? || value.empty?
        result[key] ||= []
        result[key] << value
      end
    end
    result
  end
end
