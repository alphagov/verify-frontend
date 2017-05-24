require 'rails_helper'

describe IdentityProvider do
  it 'is valid when simple_id and entity_id and levels of assurance are provided' do
    idp = IdentityProvider.new('entity_id' => 'entityId1', 'simple_id' => 'simpleId1', 'levels_of_assurance' => 'levelsOfAssurance')
    expect(idp).to be_valid
  end

  it 'is not valid when simple_id is missing' do
    idp = IdentityProvider.new('entity_id' => 'entityId1', 'levels_of_assurance' => 'levelsOfAssurance')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Simple can\'t be blank']
  end

  it 'is not valid when entity_id is missing' do
    idp = IdentityProvider.new('simple_id' => 'simpleId1', 'levels_of_assurance' => 'levelsOfAssurance')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Entity can\'t be blank']
  end

  it 'is not valid when levels_of_assurance is missing' do
    idp = IdentityProvider.new('simple_id' => 'simpleId1', 'entity_id' => 'entityId1')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Levels of assurance can\'t be blank']
  end

  it 'should convert camelCase to snake_case' do
    idp = IdentityProvider.from_api('entityId' => 'entityId1', 'simpleId' => 'simpleId1')
    expect(idp.simple_id).to eql 'simpleId1'
    expect(idp.entity_id).to eql 'entityId1'
  end

  it 'should load from session' do
    idp = IdentityProvider.from_session('entity_id' => 'entityId1', 'simple_id' => 'simpleId1')
    expect(idp.simple_id).to eql 'simpleId1'
    expect(idp.entity_id).to eql 'entityId1'
  end

  it 'should load from session' do
    provider = IdentityProvider.new('entity_id' => 'entityId1', 'simple_id' => 'simpleId1')
    idp = IdentityProvider.from_session(provider)
    expect(idp).to eql provider
  end
end
