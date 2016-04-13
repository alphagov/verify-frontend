require 'spec_helper'
require 'rails_helper'

describe WillItWorkForMeForm do
  context 'is not valid when' do
    expected_errors = ['Please answer all the questions']
    it 'no answers given' do
      form = WillItWorkForMeForm.new({})

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql expected_errors
    end

    it 'age threshold is answered, resident for last 12 months is no and non resident reason is not provided' do
      form = WillItWorkForMeForm.new(above_age_threshold: 'false', resident_last_12_months: 'false')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql expected_errors
    end

    it 'no answer for age threshold is provided and the residency questions are answered' do
      form = WillItWorkForMeForm.new(resident_last_12_months: 'false', not_resident_reason: 'AddressButNotResident')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql expected_errors
    end

    it 'no answer for age threshold is provided and the resident for last 12 months is answered yes' do
      form = WillItWorkForMeForm.new(resident_last_12_months: 'true')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql expected_errors
    end

    it 'age threshold is answered and no answer provided for residency questions' do
      form = WillItWorkForMeForm.new(above_age_threshold: 'false')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql expected_errors
    end
  end

  context 'is valid' do
    it 'when age threshold answer is yes and UK residency answer is yes' do
      form = WillItWorkForMeForm.new(above_age_threshold: 'true', resident_last_12_months: 'true')

      expect(form).to be_valid
    end

    it 'when age threshold answer is yes and UK residency answer is no and reason is given' do
      form = WillItWorkForMeForm.new(above_age_threshold: 'true', resident_last_12_months: 'false', not_resident_reason: 'AddressButNotResident')

      expect(form).to be_valid
    end
  end
end
