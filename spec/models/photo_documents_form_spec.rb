require 'spec_helper'
require 'rails_helper'

describe PhotoDocumentsForm do
  let(:form_attributes) { [:passport, :driving_licence, :ni_driving_licence, :neither_document] }

  context '#validations' do
    context '#invalid form' do
      it 'should be invalid if all inputs are empty' do
        form = PhotoDocumentsForm.new({})
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if no driving licence details are given' do
        form = PhotoDocumentsForm.new(
            any_driving_licence: 'true'
        )
        expect(form).to_not be_valid
      end

      it 'should be invalid if input is contradictory' do
        form = PhotoDocumentsForm.new(
            driving_licence: 'true',
            neither_documents: 'true'
        )
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if user only inputs driving licence details' do
        form = PhotoDocumentsForm.new(
            any_driving_licence: 'true',
            driving_licence: 'true'
        )
        expect(form).to_not be_valid
      end

      it 'should be invalid if user only inputs passport details' do
        form = PhotoDocumentsForm.new(
            passport: 'true'
        )
        expect(form).to_not be_valid
      end
    end

    context '#valid form' do
      it 'should be valid if user clicks I dont have either of these documents' do
        form = PhotoDocumentsForm.new(neither_documents: 'true')
        expect(form).to be_valid
      end

      it 'should be valid if answers are given to every question' do
        form = PhotoDocumentsForm.new(
            any_driving_licence: 'false',
            ni_driving_licence: 'false',
            driving_licence: 'false',
            passport: 'true',
        )
        expect(form).to be_valid
      end

      it 'should be valid if all document answers are false' do
        form = PhotoDocumentsForm.new(
            ni_driving_licence: 'false',
            driving_licence: 'false',
            passport: 'false',
            any_driving_licence: 'false'
        )
        expect(form).to be_valid
      end
    end
  end

  context '#selected_answers' do

    it 'should return a hash of the selected answers' do
      form = PhotoDocumentsForm.new(
          passport: 'false',
      )
      evidence = form.selected_answers
      expect(evidence).to eql(passport: false)
    end

    it 'should return a hash of the no driving licence and no ni driving licence if no selected for any driving licence' do
      form = PhotoDocumentsForm.new(
          any_driving_licence: 'false',
      )
      evidence = form.selected_answers
      expect(evidence).to eql(driving_licence: false, ni_driving_licence: false)
    end

    it 'should return a hash of driving licence true if GB driving licence selected' do
      form = PhotoDocumentsForm.new(
          any_driving_licence: 'true',
          driving_licence: 'true'
      )
      evidence = form.selected_answers
      expect(evidence).to eql(driving_licence: true)
    end

    it 'should not return selected answers when there is no value' do
      form = PhotoDocumentsForm.new(
          passport: 'true',
          any_driving_licence: ''
      )
      answers = form.selected_answers
      expect(answers).to eql(passport: true)
    end

    it 'should return all documents answers as false if I dont have either of these documents is clicked' do
      form = PhotoDocumentsForm.new(neither_documents: 'true')
      answers = form.selected_answers
      expect(answers).to eql(ni_driving_licence: false, driving_licence: false, passport: false)
    end
  end
end
