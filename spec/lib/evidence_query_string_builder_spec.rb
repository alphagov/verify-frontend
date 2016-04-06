require 'evidence_query_string_builder'

describe EvidenceQueryStringBuilder do
  it 'should return no_documents if no selected evidence provided' do
    query_string = EvidenceQueryStringBuilder.build([])
    expect(query_string).to eql 'selected-evidence=no_documents'
  end

  it 'should build a query string with one piece of evidence' do
    query_string = EvidenceQueryStringBuilder.build([:passport])
    expect(query_string).to eql 'selected-evidence=passport'
  end

  it 'should build a query string with two pieces of evidence' do
    query_string = EvidenceQueryStringBuilder.build([:passport, :driving_licence])
    expect(query_string).to eql 'selected-evidence=passport&selected-evidence=driving_licence'
  end
end
