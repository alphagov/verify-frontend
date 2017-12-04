require 'spec_helper'
require 'rails_helper'

describe CleverQuestions::SelectDocumentsForm do
  context '#validations' do
    context '#invalid form' do
      it 'should be invalid if all inputs are empty' do
        form = CleverQuestions::SelectDocumentsForm.new({})
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if no driving licence details are given' do
        form = CleverQuestions::SelectDocumentsForm.new(
          any_driving_licence: 'true',
          passport: 'false'
        )
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if user only inputs driving licence details' do
        form = CleverQuestions::SelectDocumentsForm.new(
          any_driving_licence: 'true',
          driving_licence: 'true'
        )
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      it 'should be invalid if user only inputs passport details' do
        form = CleverQuestions::SelectDocumentsForm.new(
          passport: 'true'
        )
        expect(form).to_not be_valid
        expect(form.errors.full_messages).to eql ['Please select the documents you have']
      end

      context 'passport expiry' do
        it 'should be invalid if passport expiry date not present when passport has expired' do
          form = CleverQuestions::SelectDocumentsForm.new(
            any_driving_licence: 'false',
            ni_driving_licence: 'true',
            driving_licence: 'true',
            passport: 'yes_expired'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date day element not present' do
          form = select_documents_form_with_passport_expiry(
            day: '',
            month: '1',
            year: '2017'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date month element not present' do
          form = select_documents_form_with_passport_expiry(
            day: '1',
            month: '',
            year: '2017'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date year element not present' do
          form = select_documents_form_with_passport_expiry(
            day: '1',
            month: '1',
            year: ''
           )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date day element is less than one' do
          form = select_documents_form_with_passport_expiry(
            day: '0',
            month: '1',
            year: '2017'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date day element is greater than 31' do
          form = select_documents_form_with_passport_expiry(
            day: '32',
            month: '1',
            year: '2016'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date day element is less than than 1' do
          form = select_documents_form_with_passport_expiry(
            day: '-1',
            month: '1',
            year: '2016'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date day element is not an integer' do
          form = select_documents_form_with_passport_expiry(
            day: 'aaa',
            month: '1',
            year: '2016'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date month element is less than one' do
          form = select_documents_form_with_passport_expiry(
            day: '1',
            month: '-1',
            year: '2016'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date month element is more than twelve' do
          form = select_documents_form_with_passport_expiry(
            day: '1',
            month: '14',
            year: '2016'
           )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date month element is not an integer' do
          form = select_documents_form_with_passport_expiry(
            day: '1',
            month: 'aaa',
            year: '2016'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date year element is more than this year' do
          form = select_documents_form_with_passport_expiry(
            day: '1',
            month: '1',
            year: (Date.today.year + 1).to_s
        )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date year element is less than zero' do
          form = select_documents_form_with_passport_expiry(
            day: '1',
            month: '1',
            year: '-1'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end

        it 'should be invalid if passport expiry date year element is not an integer' do
          form = select_documents_form_with_passport_expiry(
            day: '1',
            month: '1',
            year: 'aaa'
          )

          expect(form).to_not be_valid
          expect(form.errors.full_messages).to eql ['Please enter valid passport expiry date']
        end
      end
    end

    context '#valid form' do
      it 'should be valid if answers are given to every question if passpport not expired' do
        form = CleverQuestions::SelectDocumentsForm.new(
          any_driving_licence: 'false',
          ni_driving_licence: 'true',
          driving_licence: 'true',
          passport: 'true',
        )
        expect(form).to be_valid
      end

      it 'should set passport expiry details to empty if not supplied' do
        form = CleverQuestions::SelectDocumentsForm.new(
          any_driving_licence: 'false',
          ni_driving_licence: 'true',
          driving_licence: 'true',
          passport: 'true',
        )
        expect(form.passport_expiry).to eql(day: '', month: '', year: '')
      end

      it 'should be valid if answers are given to every question if passport expired' do
        form = CleverQuestions::SelectDocumentsForm.new(
          any_driving_licence: 'false',
          ni_driving_licence: 'true',
          driving_licence: 'true',
          passport: 'yes_expired',
          passport_expiry: {
            day: Date.today.day.to_s,
            month: Date.today.month.to_s,
            year: Date.today.year.to_s
          }
        )
        expect(form).to be_valid
      end
    end
  end

  context '#selected_answers' do
    it 'should return a hash of the selected answers' do
      form = CleverQuestions::SelectDocumentsForm.new(
        passport: 'false',
      )
      evidence = form.selected_answers
      expect(evidence).to eql(passport: false)
    end

    it 'should return a hash of the no driving licence and no ni driving licence if no selected for any driving licence' do
      form = CleverQuestions::SelectDocumentsForm.new(
        any_driving_licence: 'false',
      )
      evidence = form.selected_answers
      expect(evidence).to eql(driving_licence: false, ni_driving_licence: false)
    end

    it 'should return a hash of driving licence true if GB driving licence selected' do
      form = CleverQuestions::SelectDocumentsForm.new(
        any_driving_licence: 'true',
        driving_licence: 'true'
      )
      evidence = form.selected_answers
      expect(evidence).to eql(driving_licence: true)
    end

    it 'should not return selected answers when there it is not an eligible IDP evidence ' do
      form = CleverQuestions::SelectDocumentsForm.new(
        passport: 'true',
        any_driving_licence: ''
      )
      answers = form.selected_answers
      expect(answers).to eql(passport: true)
    end

    it 'has passport if expired under 6 months' do
      date_in_past = Date.today - 2.months
      form = CleverQuestions::SelectDocumentsForm.new(
        passport: 'yes_expired',
        passport_expiry: {
          day: date_in_past.day.to_s,
          month: date_in_past.month.to_s,
          year: date_in_past.year.to_s
        }
      )
      evidence = form.selected_answers
      expect(evidence).to eql(passport: true)
    end

    it 'has passport if expired exactly 6 months' do
      date_in_past = Date.today - 6.months
      form = CleverQuestions::SelectDocumentsForm.new(
        passport: 'yes_expired',
        passport_expiry: {
          day: date_in_past.day.to_s,
          month: date_in_past.month.to_s,
          year: date_in_past.year.to_s
        }
      )
      evidence = form.selected_answers
      expect(evidence).to eql(passport: true)
    end

    it 'has no passport if expired over 6 months' do
      date_in_past = Date.today - 7.months
      form = CleverQuestions::SelectDocumentsForm.new(
        passport: 'yes_expired',
        passport_expiry: {
          day: date_in_past.day.to_s,
          month: date_in_past.month.to_s,
          year: date_in_past.year.to_s
        }
      )
      evidence = form.selected_answers
      expect(evidence).to eql(passport: false)
    end

    it 'has no passport if expired 6 months and 1 day' do
      date_in_past = Date.today - 6.months - 1.day
      form = CleverQuestions::SelectDocumentsForm.new(
        passport: 'yes_expired',
        passport_expiry: {
          day: date_in_past.day.to_s,
          month: date_in_past.month.to_s,
          year: date_in_past.year.to_s
        }
      )
      evidence = form.selected_answers
      expect(evidence).to eql(passport: false)
    end
  end

  context '#further identity information' do
    it 'should require further information when user has neither uk passport or driving licence' do
      form = CleverQuestions::SelectDocumentsForm.new(
        any_driving_licence: 'false',
        passport: 'false'
      )
      expect(form).to be_further_id_information_required
    end

    it 'should not require further information when user has a northern ireland driving licence' do
      form = CleverQuestions::SelectDocumentsForm.new(
        any_driving_licence: 'true',
        ni_driving_licence: 'true',
        passport: 'false'
      )
      expect(form).to_not be_further_id_information_required
    end

    it 'should not require further information when user has a GB driving licence' do
      form = CleverQuestions::SelectDocumentsForm.new(
        any_driving_licence: 'true',
        driving_licence: 'true',
        passport: 'false'
      )
      expect(form).to_not be_further_id_information_required
    end

    it 'should not require further information when user has a UK passport' do
      form = CleverQuestions::SelectDocumentsForm.new(
        any_driving_licence: 'false',
        passport: 'true'
      )
      expect(form).to_not be_further_id_information_required
    end
  end

private

  def select_documents_form_with_passport_expiry(passport_expiry)
    CleverQuestions::SelectDocumentsForm.new(
      any_driving_licence: 'false',
      ni_driving_licence: 'true',
      driving_licence: 'true',
      passport: 'yes_expired',
      passport_expiry: passport_expiry
    )
  end
end
