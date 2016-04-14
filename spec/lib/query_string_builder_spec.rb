require 'query_string_builder'

describe QueryStringBuilder do
  it 'should return no_documents if no selected evidence provided' do
    query_string = QueryStringBuilder.build([])
    expect(query_string).to eql ''
  end

  it 'should build a query string with one key value pair' do
    query_string = QueryStringBuilder.build('key1' => :value1)
    expect(query_string).to eql 'key1=value1'
  end

  it 'should build a query string with one key with two values' do
    query_string = QueryStringBuilder.build('key1' => [:value1, :value2])
    expect(query_string).to eql 'key1=value1&key1=value2'
  end

  it 'should build a query string with two keys and two values' do
    query_string = QueryStringBuilder.build('key1' => :value1, 'key2' => :value2)
    expect(query_string).to eql 'key1=value1&key2=value2'
  end
end
