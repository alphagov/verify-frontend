require 'spec_helper'
require 'rails_helper'

describe CleverQuestions::SelectProofOfAddressForm do
  PROOF_OF_ADDRESS_TRANSLATION = 'clever_questions.hub.select_proof_of_address'.freeze

  context 'form validity' do
    it 'should return true if form is valid' do
      form = CleverQuestions::SelectProofOfAddressForm.new(uk_bank_account_details: 'true', debit_card: 'false', credit_card: 'false')

      expect(form.valid?).to be true
    end

    it 'should return false when all form fields are nil' do
      form = CleverQuestions::SelectProofOfAddressForm.new(uk_bank_account_details: nil, debit_card: nil, credit_card: nil)

      expect(form.valid?).to be false
    end

    it 'should return false when only bank account is nil' do
      form = CleverQuestions::SelectProofOfAddressForm.new(uk_bank_account_details: nil, debit_card: 'true', credit_card: 'true')

      expect(form.valid?).to be false
    end

    it 'should return false when only debit card is nil' do
      form = CleverQuestions::SelectProofOfAddressForm.new(uk_bank_account_details: 'true', debit_card: nil, credit_card: 'true')

      expect(form.valid?).to be false
    end

    it 'should return false when only credit card is nil' do
      form = CleverQuestions::SelectProofOfAddressForm.new(uk_bank_account_details: 'true', debit_card: 'true', credit_card: nil)

      expect(form.valid?).to be false
    end
  end

  context 'error message' do
    it 'show an error message when any form field is nil' do
      form = CleverQuestions::SelectProofOfAddressForm.new({})

      form.valid?

      expect(form.errors.full_messages).to eql [I18n.t("#{PROOF_OF_ADDRESS_TRANSLATION}.errors.no_selection")]
    end

    it 'show an error message when bank account is nil' do
      form = CleverQuestions::SelectProofOfAddressForm.new(uk_bank_account_details: nil, debit_card: 'true', credit_card: 'true')

      form.valid?

      expect(form.errors.full_messages).to eql [I18n.t("#{PROOF_OF_ADDRESS_TRANSLATION}.errors.no_selection")]
    end

    it 'show an error message when debit card is nil' do
      form = CleverQuestions::SelectProofOfAddressForm.new(uk_bank_account_details: 'true', debit_card: nil, credit_card: 'true')

      form.valid?

      expect(form.errors.full_messages).to eql [I18n.t("#{PROOF_OF_ADDRESS_TRANSLATION}.errors.no_selection")]
    end

    it 'show an error message when credit card is nil' do
      form = CleverQuestions::SelectProofOfAddressForm.new(uk_bank_account_details: 'true', debit_card: 'true', credit_card: nil)

      form.valid?

      expect(form.errors.full_messages).to eql [I18n.t("#{PROOF_OF_ADDRESS_TRANSLATION}.errors.no_selection")]
    end
  end
end
