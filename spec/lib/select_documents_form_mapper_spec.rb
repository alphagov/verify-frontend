require 'spec_helper'
require 'select_documents_form_mapper'

describe SelectDocumentsFormMapper do
  it 'maps old frontend form parameters to new front parameters' do
    params = { 'driving_licence' => 'false', 'passport' => 'false', 'non_uk_id_document' => 'false', 'no_documents' => 'true' }
    actual = SelectDocumentsFormMapper.map(params)
    expect(actual).to eql(params)
  end

  it 'adds no_documents parameter if missing' do
    params = { 'driving_licence' => 'true' }
    expected = { 'driving_licence' => 'true', 'no_documents' => 'false' }
    actual = SelectDocumentsFormMapper.map(params)
    expect(actual).to eql(expected)
  end

  it 'uses select_documents_form fields from new frontend when they exist' do
    params = { 'select_documents_form' => { 'driving_licence' => 'true', 'no_documents' => 'false' } }
    actual = SelectDocumentsFormMapper.map(params)
    expected = { 'driving_licence' => 'true', 'no_documents' => 'false' }
    expect(actual).to eql(expected)
  end
end
