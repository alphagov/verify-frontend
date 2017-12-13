require 'spec_helper'
require 'rails_helper'

describe SelectDocumentsForm do
  context '#validations' do
    context '#invalid form' do
      it 'should be invalid if all inputs are empty' do
        form = SelectDocumentsForm.new({})
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if no driving licence details are given' do
        form = SelectDocumentsForm.new(
          any_driving_licence: 'true',
          passport: 'false'
        )
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if user only inputs driving licence details' do
        form = SelectDocumentsForm.new(
          any_driving_licence: 'true',
          driving_licence: 'great_britain'
        )
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if user only inputs passport details' do
        form = SelectDocumentsForm.new(
          passport: 'true'
        )
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end
    end

    context '#valid form' do
      it 'should be valid if answers are given to every question' do
        form = SelectDocumentsForm.new(
          any_driving_licence: 'false',
          passport: 'true',
        )
        expect(form).to be_valid
      end
    end
  end

  context '#selected_answers' do
    it 'should return a hash of the selected answers' do
      form = SelectDocumentsForm.new(
        passport: 'false',
      )
      evidence = form.selected_answers
      expect(evidence).to eql(passport: false)
    end

    it 'should return a hash of the no driving licence and no ni driving licence if no selected for any driving licence' do
      form = SelectDocumentsForm.new(
        any_driving_licence: 'false',
      )
      evidence = form.selected_answers
      expect(evidence).to eql(driving_licence: false, ni_driving_licence: false)
    end

    it 'should return a hash of driving licence true if GB driving licence selected' do
      form = SelectDocumentsForm.new(
        any_driving_licence: 'true',
        driving_licence: 'great_britain'
      )
      evidence = form.selected_answers
      expect(evidence).to eql(driving_licence: true, ni_driving_licence: false)
    end

    it 'should not return selected answers when there it is not an eligible IDP evidence ' do
      form = SelectDocumentsForm.new(
        passport: 'true',
        any_driving_licence: ''
      )
      answers = form.selected_answers
      expect(answers).to eql(passport: true)
    end
  end

  context '#further identity information' do
    it 'should require further information when user has neither uk passport or driving licence' do
      form = SelectDocumentsForm.new(
        any_driving_licence: 'false',
        passport: 'false'
      )
      expect(form).to be_further_id_information_required
    end

    it 'should not require further information when user has a northern ireland driving licence' do
      form = SelectDocumentsForm.new(
        any_driving_licence: 'true',
        driving_licence: 'northern_ireland',
        passport: 'false'
      )
      expect(form).to_not be_further_id_information_required
    end

    it 'should not require further information when user has a GB driving licence' do
      form = SelectDocumentsForm.new(
        any_driving_licence: 'true',
        driving_licence: 'great_britain',
        passport: 'false'
      )
      expect(form).to_not be_further_id_information_required
    end

    it 'should not require further information when user has a UK passport' do
      form = SelectDocumentsForm.new(
        any_driving_licence: 'false',
        passport: 'true'
      )
      expect(form).to_not be_further_id_information_required
    end
  end
end
