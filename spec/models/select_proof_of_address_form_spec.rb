require 'spec_helper'
require 'rails_helper'

describe SelectProofOfAddressForm do
  it 'should return a hash of true selected answers' do
    form = SelectProofOfAddressForm.new(bank_account: 'true', debit_card: 'true', credit_card: 'true')

    expect(form.selected_answers).to eql(bank_account: true, debit_card: true, credit_card: true)
  end

  it 'should return a hash of false selected answers' do
    form = SelectProofOfAddressForm.new(bank_account: 'false', debit_card: 'false', credit_card: 'false')

    expect(form.selected_answers).to eql(bank_account: false, debit_card: false, credit_card: false)
  end

  it 'should not return any answers that contain no value' do
    form = SelectProofOfAddressForm.new(bank_account: 'true', debit_card: 'true', credit_card: '')

    expect(form.selected_answers).to eql(bank_account: true, debit_card: true)
  end
end
