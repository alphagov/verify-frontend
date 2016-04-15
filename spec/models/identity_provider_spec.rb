require 'rails_helper'

RSpec.describe IdentityProvider do
  it 'is valid when simpleId and entityId are provided' do
    idp = IdentityProvider.new('entityId' => 'entityId1', 'simpleId' => 'simpleId1')
    expect(idp).to be_valid
  end

  it 'is not valid when simpleId is missing' do
    idp = IdentityProvider.new('entityId' => 'entityId1')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Simple can\'t be blank']
  end

  it 'is valid when simpleId and entityId are provided' do
    idp = IdentityProvider.new('simpleId' => 'simpleId1')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Entity can\'t be blank']
  end
end
