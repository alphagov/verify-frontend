require 'spec_helper'
require 'rails_helper'

describe SelectDocumentsForm do
  it 'should be invalid if all inputs are empty' do
    form = SelectDocumentsForm.new({})
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please select the documents you have']
  end

  it 'should be invalid if user selects No for one document and leaves the others blank' do
    form = SelectDocumentsForm.new(
      driving_licence: 'false'
    )
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please select the documents you have']
  end

  it 'should be valid if user selects No docs only' do
    form = SelectDocumentsForm.new(
      no_documents: 'true'
    )
    expect(form).to be_valid
  end

  it 'should be valid if answers are given to every question' do
    form = SelectDocumentsForm.new(
      driving_licence: 'false',
      passport: 'true',
      non_uk_id_document: 'false'
    )
    expect(form).to be_valid
  end

  it 'should be valid if one Yes is selected' do
    form = SelectDocumentsForm.new(
      passport: 'true'
    )
    expect(form).to be_valid
  end

  it 'should be valid if all document answers are false' do
    form = SelectDocumentsForm.new(
      driving_licence: 'false',
      passport: 'false',
      non_uk_id_document: 'false'
    )
    expect(form).to be_valid
  end

  it 'should be invalid if input is contradictory' do
    form = SelectDocumentsForm.new(
      driving_licence: 'true',
      passport: 'true',
      non_uk_id_document: 'true',
      no_documents: 'true'
    )
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please check your selection']
  end

  describe '#selected_evidence' do
    it 'should return a list of the selected evidence' do
      form = SelectDocumentsForm.new(
        driving_licence: 'true',
        passport: 'true',
        non_uk_id_document: 'false',
        no_documents: 'false'
      )
      evidence = form.selected_evidence
      expect(evidence).to eql([:passport, :driving_licence])
    end

    it 'should return a list of the selected evidence when there is an empty value' do
      form = SelectDocumentsForm.new(
        driving_licence: 'true',
        passport: '',
        non_uk_id_document: 'false',
        no_documents: 'false'
      )
      evidence = form.selected_evidence
      expect(evidence).to eql([:driving_licence])
    end
  end
end
