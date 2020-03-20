require 'rails_helper'

describe IdentityProvider do
  it 'is valid when simpleId and entityId and levels of assurance are provided' do
    idp = IdentityProvider.new('entityId' => 'entityId1', 'simpleId' => 'simpleId1', 'levelsOfAssurance' => 'levelsOfAssurance')
    expect(idp).to be_valid
  end

  it 'is not valid when simpleId is missing' do
    idp = IdentityProvider.new('entityId' => 'entityId1', 'levelsOfAssurance' => 'levelsOfAssurance')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Simple can\'t be blank']
  end

  it 'is not valid when entityId is missing' do
    idp = IdentityProvider.new('simpleId' => 'simpleId1', 'levelsOfAssurance' => 'levelsOfAssurance')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Entity can\'t be blank']
  end

  it 'is not valid when levelsOfAssurance is missing' do
    idp = IdentityProvider.new('simpleId' => 'simpleId1', 'entityId' => 'entityId1')
    expect(idp).to_not be_valid
    expect(idp.errors.full_messages).to eql ['Levels of assurance can\'t be blank']
  end

  it 'provides authentication by default if no value is supplied' do
    idp = IdentityProvider.new('simpleId' => 'simpleId1', 'entityId' => 'entityId1')
    expect(idp.authentication_enabled).to eql true
  end

  it 'provides no authentication when authentication enabled is set to false' do
    idp = IdentityProvider.new('simpleId' => 'simpleId1', 'entityId' => 'entityId1', 'authenticationEnabled' => false)
    expect(idp.authentication_enabled).to eql false
  end

  it 'provides provide registration until date if it is supplied' do
    idp = IdentityProvider.new('simpleId' => 'simpleId1', 'entityId' => 'entityId1', 'provideRegistrationUntil' => '2020-03-10T11:15:30+00:00')
    expect(idp.provide_registration_until.year).to eql 2020
    expect(idp.provide_registration_until.month).to eql 3
    expect(idp.provide_registration_until.day).to eql 10
    expect(idp.provide_registration_until.hour).to eql 11
    expect(idp.provide_registration_until.min).to eql 15
    expect(idp.provide_registration_until.second).to eql 30
  end
end
