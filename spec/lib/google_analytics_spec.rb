require 'google_analytics'
require 'active_support/core_ext/string'

RSpec.describe GoogleAnalytics do
  it 'has an account id' do
    ga = GoogleAnalytics.new('UA-123456-1', [])
    expect(ga.tracker_id).to eql 'UA-123456-1'
  end

  it 'is disabled when account ID is nil' do
    ga = GoogleAnalytics.new(nil, [])
    expect(ga.enabled?).to eql false
  end

  it 'is disabled when account ID is an empty string' do
    ga = GoogleAnalytics.new('', [])
    expect(ga.enabled?).to eql false
  end

  it 'is enabled when account ID is present' do
    ga = GoogleAnalytics.new('UA-123456-1', [])
    expect(ga.enabled?).to eql true
  end
end
