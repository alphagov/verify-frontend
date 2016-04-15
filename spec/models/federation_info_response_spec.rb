require 'spec_helper'
require 'rails_helper'

describe FederationInfoResponse do
  it 'is invalid when idps aren\'t valid' do
    federation = FederationInfoResponse.new('idps' => [{}])
    expect(federation).to_not be_valid
    expect(federation.errors.full_messages).to include 'Identity providers are malformed'
  end

  it 'can be valid with an empty list of idps' do
    federation = FederationInfoResponse.new('idps' => [])
    federation.valid?
    expect(federation.errors.full_messages).to_not include 'Identity providers are malformed'
  end
end
