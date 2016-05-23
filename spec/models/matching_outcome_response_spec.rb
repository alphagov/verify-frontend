require 'spec_helper'
require 'rails_helper'

describe MatchingOutcomeResponse do
  it 'should be invalid with an unknown outcome value' do
    expect(MatchingOutcomeResponse.new('outcome' => 'BANANA').valid?).to eql(false)
  end

  it 'should be valid with an expected outcome value' do
    expect(MatchingOutcomeResponse.new('outcome' => 'WAIT').valid?).to eql(true)
  end
end
