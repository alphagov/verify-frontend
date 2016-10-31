require 'spec_helper'
require 'rails_helper'

describe SelectDocumentsForm do
  let(:form_attributes) { [:passport, :driving_licence, :ni_driving_licence, :non_uk_id_document] }

  it 'should be invalid if all inputs are empty' do
    form = SelectDocumentsForm.new({}, form_attributes)
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please select the documents you have']
  end

  it 'should be invalid if user selects No for one document and leaves the others blank' do
    form = SelectDocumentsForm.new(
      { driving_licence: 'false' },
      form_attributes
    )
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please select the documents you have']
  end

  it 'should be valid if user selects No docs only' do
    form = SelectDocumentsForm.new(
      { no_documents: 'true' },
      form_attributes
    )
    expect(form).to be_valid
  end

  it 'should be valid if answers are given to every question' do
    form = SelectDocumentsForm.new(
      { driving_licence: 'false',
      passport: 'true',
      non_uk_id_document: 'false' },
      form_attributes
    )
    expect(form).to be_valid
  end

  it 'should be valid if one Yes is selected' do
    form = SelectDocumentsForm.new(
      { passport: 'true' },
      form_attributes
    )
    expect(form).to be_valid
  end

  it 'should be valid if all document answers are false' do
    form = SelectDocumentsForm.new(
      { ni_driving_licence: 'false',
      driving_licence: 'false',
      passport: 'false',
      non_uk_id_document: 'false',
      uk_bank_account_details: 'false',
      debit_card: 'false',
      credit_card: 'false' },
      form_attributes
    )
    expect(form).to be_valid
  end

  it 'should be invalid if input is contradictory' do
    form = SelectDocumentsForm.new(
      { driving_licence: 'true',
      passport: 'true',
      non_uk_id_document: 'true',
      no_documents: 'true' },
      form_attributes
    )
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please check your selection']
  end

  describe '#selected_answers' do
    it 'should return a hash of the selected answers' do
      form = SelectDocumentsForm.new(
        { driving_licence: 'true',
        passport: 'true',
        non_uk_id_document: 'false',
        no_documents: 'false' },
        form_attributes
      )
      evidence = form.selected_answers
      expect(evidence).to eql(passport: true, driving_licence: true, non_uk_id_document: false)
    end

    it 'should not return selected answers when there is no value' do
      form = SelectDocumentsForm.new(
        { driving_licence: 'true',
        non_uk_id_document: '',
        no_documents: 'false' },
        form_attributes
      )
      answers = form.selected_answers
      expect(answers).to eql(driving_licence: true)
    end

    it 'should return all documents answers as false if no documents is checked' do
      form = SelectDocumentsForm.new(
        { no_documents: 'true' },
        form_attributes
      )
      answers = form.selected_answers
      expect(answers).to eql(ni_driving_licence: false, driving_licence: false, passport: false, non_uk_id_document: false)
    end
  end
end
