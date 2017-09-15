require 'spec_helper'
require 'rails_helper'

describe SelectPhoneVariantForm do
  it 'should be invalid when neither mobile nor smartphone answered' do
    test_form_missing_data
    test_form_missing_data landline: 'false'
    test_form_missing_data landline: 'true'
  end

  it 'should be valid when smartphone is answered and mobile phone is unanswered' do
    test_form_valid smart_phone: 'false'
    test_form_valid smart_phone: 'false', landline: 'false'
    test_form_valid smart_phone: 'false', landline: 'true'

    test_form_valid smart_phone: 'true'
    test_form_valid smart_phone: 'reluctant_yes'

    test_form_valid smart_phone: 'true', landline: 'false'
    test_form_valid smart_phone: 'reluctant_yes', landline: 'false'

    test_form_valid smart_phone: 'true', landline: 'true'
    test_form_valid smart_phone: 'reluctant_yes', landline: 'true'
  end

  it 'should be invalid when mobile answered no and landline is not answered' do
    test_form_missing_data mobile_phone: 'false'
    test_form_missing_data mobile_phone: 'false', smart_phone: 'false'
  end

  it 'should be valid when mobile is answered no and landline is answered' do
    test_form_valid mobile_phone: 'false', landline: 'false'
    test_form_valid mobile_phone: 'false', landline: 'true'
    test_form_valid mobile_phone: 'false', smart_phone: 'false', landline: 'false'
    test_form_valid mobile_phone: 'false', smart_phone: 'false', landline: 'true'
  end

  it 'should be invalid when mobile is answered no and smartphone is answered yes' do
    test_form_inconsistent_data mobile_phone: 'false', smart_phone: 'true'
    test_form_inconsistent_data mobile_phone: 'false', smart_phone: 'true', landline: 'false'
    test_form_inconsistent_data mobile_phone: 'false', smart_phone: 'true', landline: 'true'

    test_form_inconsistent_data mobile_phone: 'false', smart_phone: 'reluctant_yes'
    test_form_inconsistent_data mobile_phone: 'false', smart_phone: 'reluctant_yes', landline: 'false'
    test_form_inconsistent_data mobile_phone: 'false', smart_phone: 'reluctant_yes', landline: 'true'
  end

  it 'should be invalid when mobile is answered yes and smartphone is unanswered' do
    test_form_missing_data mobile_phone: 'true'
    test_form_missing_data mobile_phone: 'true', landline: 'false'
    test_form_missing_data mobile_phone: 'true', landline: 'true'
  end

  it 'should be valid when mobile is answered yes and smartphone is answered' do
    test_form_valid mobile_phone: 'true', smart_phone: 'false'
    test_form_valid mobile_phone: 'true', smart_phone: 'false', landline: 'false'
    test_form_valid mobile_phone: 'true', smart_phone: 'false', landline: 'true'
    test_form_valid mobile_phone: 'true', smart_phone: 'true'
    test_form_valid mobile_phone: 'true', smart_phone: 'true', landline: 'false'
    test_form_valid mobile_phone: 'true', smart_phone: 'true', landline: 'true'
    test_form_valid mobile_phone: 'true', smart_phone: 'reluctant_yes'
    test_form_valid mobile_phone: 'true', smart_phone: 'reluctant_yes', landline: 'false'
    test_form_valid mobile_phone: 'true', smart_phone: 'reluctant_yes', landline: 'true'
  end

  describe '#selected_answers' do
    it 'should return a hash of the selected answers' do
      form = SelectPhoneVariantForm.new(
        mobile_phone: 'true'
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: true)
    end

    it 'should not return selected answers when there is no value' do
      form = SelectPhoneVariantForm.new(
        mobile_phone: 'false',
        smart_phone: ''
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: false)
    end

    it 'should return smartphone when the selected phone option is yes but Id prefer not to' do
      form = SelectPhoneVariantForm.new(
        mobile_phone: 'true',
        smart_phone: 'reluctant_yes'
      )
      answers = form.selected_answers
      expect(answers).to eql(mobile_phone: true, smart_phone: true)
    end
  end

  def test_form_valid(form_fields = {})
    form = SelectPhoneVariantForm.new(form_fields)
    expect(form.valid?).to eql true
    expect(form.errors.full_messages).to eql []
  end

  def test_form_missing_data(form_fields = {})
    form = SelectPhoneVariantForm.new(form_fields)
    expect(form.valid?).to eql false
    expect(form.errors.full_messages).to eql ['Please answer all the questions']
  end

  def test_form_inconsistent_data(form_fields = {})
    form = SelectPhoneVariantForm.new(form_fields)
    expect(form.valid?).to eql false
    expect(form.errors.full_messages).to eql ['Please check your selection']
  end
end
