require 'query_string_parser'

describe QueryStringParser do
  it 'should return an empty hash when no parameters are found' do
    result = QueryStringParser.parse('')
    expect(result).to eql({})
  end

  it 'should return repeated parameters in an array' do
    result = QueryStringParser.parse('key=value1&key=value2')
    expect(result).to eql('key' => %w(value1 value2))
  end

  it 'should return single parameters in an array' do
    result = QueryStringParser.parse('key=value')
    expect(result).to eql('key' => ['value'])
  end

  it 'should ignore empty values' do
    result = QueryStringParser.parse('key=&key=value')
    expect(result).to eql('key' => ['value'])
  end

  it 'should ignore empty values' do
    result = QueryStringParser.parse('key')
    expect(result).to eql({})
  end
end
