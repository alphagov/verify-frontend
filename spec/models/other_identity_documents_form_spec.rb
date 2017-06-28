require 'spec_helper'
require 'rails_helper'

describe OtherIdentityDocumentsForm do
  context '#validations' do
    context '#invalid form' do
      it 'should be invalid if all inputs are empty' do
        form = OtherIdentityDocumentsForm.new({})
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if input is not true or false' do
        form = OtherIdentityDocumentsForm.new(non_uk_id_document: 'bla')
        expect(form).to_not be_valid
      end
    end

    context '#valid form' do
      it 'should be valid if yes selected' do
        form = OtherIdentityDocumentsForm.new(non_uk_id_document: 'true')
        expect(form).to be_valid
      end

      it 'should be valid if no selected' do
        form = OtherIdentityDocumentsForm.new(non_uk_id_document: 'false')
        expect(form).to be_valid
      end
    end
  end

  context '#hash selected_answers' do
    it 'should return false if selected answer is false' do
      form = OtherIdentityDocumentsForm.new(non_uk_id_document: 'false')
      evidence = form.selected_answers
      expect(evidence).to eql(non_uk_id_document: false)
    end

    it 'should return true if selected answer is true' do
      form = OtherIdentityDocumentsForm.new(non_uk_id_document: 'true')
      evidence = form.selected_answers
      expect(evidence).to eql(non_uk_id_document: true)
    end
  end
end
