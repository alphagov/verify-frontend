require 'spec_helper'
require 'select_phone_form_mapper'

describe SelectPhoneFormMapper do
  it 'translates landline_phone parameter name to landline' do
    params = { 'mobile_phone' => 'true', 'smart_phone' => 'true', 'landline_phone' => 'false' }
    actual = SelectPhoneFormMapper.map(params)
    expected = { 'mobile_phone' => 'true', 'smart_phone' => 'true', 'landline' => 'false' }
    expect(actual).to eql(expected)
  end

  it 'uses select_phone_form fields from new frontend when they exist' do
    params = { 'select_phone_form' => { 'mobile_phone' => 'true', 'smart_phone' => 'true' } }
    actual = SelectPhoneFormMapper.map(params)
    expected = { 'mobile_phone' => 'true', 'smart_phone' => 'true' }
    expect(actual).to eql(expected)
  end
end
