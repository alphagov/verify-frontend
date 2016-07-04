require 'spec_helper'
require 'rails_helper'

describe CycleThreeAttributeResponse do
  it 'is invalid when name is not present' do
    cycle_three_attribute_response = CycleThreeAttributeResponse.new({})
    expect(cycle_three_attribute_response).to_not be_valid
    expect(cycle_three_attribute_response.errors.full_messages).to include "Name can't be blank"
  end
end
