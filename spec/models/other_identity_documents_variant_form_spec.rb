require 'spec_helper'
require 'rails_helper'

describe OtherIdentityDocumentsVariantForm do
  context '#validations' do
    context '#invalid form' do
      it 'should be invalid if all inputs are empty' do
        form = OtherIdentityDocumentsVariantForm.new({})
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please answer all the questions']
      end

      it 'should be invalid if input is not true or false' do
        form = OtherIdentityDocumentsVariantForm.new(non_uk_id_document: 'bla')
        expect(form).to_not be_valid
      end

      it 'should be invalid if other documents is true but smartphone is not defined' do
        form = OtherIdentityDocumentsVariantForm.new(non_uk_id_document: 'true')
        expect(form).to_not be_valid
      end
    end

    context '#valid form' do
      it 'should be valid if no selected' do
        form = OtherIdentityDocumentsVariantForm.new(non_uk_id_document: 'false')
        expect(form).to be_valid
      end

      it 'should be valid if yes selected and smartphone selected' do
        form = OtherIdentityDocumentsVariantForm.new(non_uk_id_document: 'true', smart_phone: 'true')
        expect(form).to be_valid
      end
    end
  end

  context '#hash selected_answers' do
    it 'should return false if selected answer is false' do
      form = OtherIdentityDocumentsVariantForm.new(non_uk_id_document: 'false')
      evidence = form.selected_answers
      expect(evidence).to eql(non_uk_id_document: false, smart_phone: false)
    end

    it 'should return true and false if selected answer is true and false' do
      form = OtherIdentityDocumentsVariantForm.new(non_uk_id_document: 'true', smart_phone: 'false')
      evidence = form.selected_answers
      expect(evidence).to eql(non_uk_id_document: true, smart_phone: false)
    end
  end
end
