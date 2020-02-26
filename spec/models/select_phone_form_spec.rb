require 'spec_helper'
require 'rails_helper'

describe SelectPhoneForm do
  mobile_phone_error = 'Mobile phone true ' + I18n.t('hub.select_phone.errors.mobile_phone')
  mobile_phone_invalid_error = 'Mobile phone true ' + I18n.t('hub.select_phone.errors.invalid_selection')
  smart_phone_error = 'Smart phone true ' + I18n.t('hub.select_phone.errors.smart_phone')
  smart_phone_invalid_error = 'Smart phone true ' + I18n.t('hub.select_phone.errors.invalid_selection')

  describe 'should be valid' do
    it 'when mobile is answered yes and smartphone is answered' do
      %w(true false do_not_know).each do |smart_phone_answer|
        form = SelectPhoneForm.new(mobile_phone: 'true', smart_phone: smart_phone_answer)

        expect(form.valid?).to eql true
        expect(form.errors.full_messages).to eql []
      end
    end

    it 'when mobile is answered no and smartphone is unanswered' do
      form = SelectPhoneForm.new(mobile_phone: 'false')

      expect(form.valid?).to eql true
      expect(form.errors.full_messages).to eql []
    end

    it 'when smartphone is answered and mobile phone is unanswered' do
      %w(true false do_not_know).each do |smart_phone_answer|
        form = SelectPhoneForm.new(smart_phone: smart_phone_answer)

        expect(form.valid?).to eql true
        expect(form.errors.full_messages).to eql []
      end
    end
  end

  describe 'should be invalid' do
    it 'when mobile is answered no and smartphone is answered yes' do
      form = SelectPhoneForm.new(mobile_phone: 'false', smart_phone: 'true')

      expect(form.valid?).to eql false
      expect(form.errors.full_messages).to eql [mobile_phone_invalid_error, smart_phone_invalid_error]
    end

    it 'when neither mobile nor smartphone answered' do
      form = SelectPhoneForm.new({})

      expect(form.valid?).to eql false
      expect(form.errors.full_messages).to eql [mobile_phone_error]
    end

    it 'when mobile is answered yes and smartphone is unanswered' do
      form = SelectPhoneForm.new(mobile_phone: 'true')

      expect(form.valid?).to eql false
      expect(form.errors.full_messages).to eql [smart_phone_error]
    end
  end

  describe '#selected_answers' do
    it 'should return a hash of the selected answers' do
      form = SelectPhoneForm.new(
        mobile_phone: 'true'
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: true)
    end

    it 'should not return selected answers when there is no value' do
      form = SelectPhoneForm.new(
        mobile_phone: 'false',
        smart_phone: ''
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: false)
    end

    it 'should not return smart_phone when the answer is do not know' do
      form = SelectPhoneForm.new(
        mobile_phone: 'true',
        smart_phone: 'do_not_know'
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: true)
    end
  end
end
