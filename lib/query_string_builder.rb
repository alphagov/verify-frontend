class QueryStringBuilder
  def self.build(params)
    params.collect { |key, value|
      [*value].collect { |item| "#{key}=#{item}" }
    }.join('&')
  end
end
