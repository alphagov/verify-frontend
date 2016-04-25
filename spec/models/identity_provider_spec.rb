require 'rails_helper'

RSpec.describe IdentityProvider do
  it 'is valid when simple_id and entity_id are provided' do
    idp = IdentityProvider.new('entity_id' => 'entityId1', 'simple_id' => 'simpleId1')
    expect(idp).to be_valid
  end

  it 'is not valid when simple_id is missing' do
    idp = IdentityProvider.new('entity_id' => 'entityId1')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Simple can\'t be blank']
  end

  it 'is valid when simple_id and entity_id are provided' do
    idp = IdentityProvider.new('simple_id' => 'simpleId1')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Entity can\'t be blank']
  end

  it 'should convert camelCase to snake_case' do
    idp = IdentityProvider.from_api('entityId' => 'entityId1', 'simpleId' => 'simpleId1')
    expect(idp.simple_id).to eql 'simpleId1'
    expect(idp.entity_id).to eql 'entityId1'
  end
end
