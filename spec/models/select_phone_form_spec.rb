require 'spec_helper'
require 'rails_helper'

describe SelectPhoneForm do
  # invalid
  it 'should be invalid if all inputs are empty' do
    form = SelectPhoneForm.new({})
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please answer the question']
  end

  it 'should be invalid if user has mobile phone but does not specify which type' do
    form = SelectPhoneForm.new(mobile_phone: 'true')
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please answer the question']
  end

  it 'should be invalid if user has no mobile phone and does not specify landline' do
    form = SelectPhoneForm.new(mobile_phone: 'false')
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please answer the question']
  end

  it 'should be invalid if user has no mobile phone but can install apps' do
    form = SelectPhoneForm.new(mobile_phone: 'false', smart_phone: 'true')
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please check your selection']
  end

  it 'should be invalid if user only answers landline' do
    form = SelectPhoneForm.new(landline: 'false')
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please answer the question']
  end

  it 'should be invalid if user answers yes to mobile phone but does not answer smartphone question' do
    form = SelectPhoneForm.new(mobile_phone: 'true')
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please answer the question']
  end

  it 'should be invalid if user answers no to mobile phone and no to smart phone, but does not answer landline' do
    form = SelectPhoneForm.new(mobile_phone: 'false', smart_phone: 'false')
    expect(form).to_not be_valid
    expect(form.errors.full_messages).to eql ['Please answer the question']
  end

  # valid

  it 'should be valid if user has mobile phone and answers no to smart phone question' do
    form = SelectPhoneForm.new(mobile_phone: 'true', smart_phone: 'false')
    expect(form).to be_valid
  end

  it 'should be valid if user has landline and no mobile phone' do
    form = SelectPhoneForm.new(mobile_phone: 'false', landline: 'true')
    expect(form).to be_valid
  end

  it 'should be valid if user has landline and smartphone' do
    form = SelectPhoneForm.new(smart_phone: 'true', landline: 'true')
    expect(form).to be_valid
  end

  it 'should be valid if user has smartphone' do
    form = SelectPhoneForm.new(smart_phone: 'true')
    expect(form).to be_valid
  end
end
