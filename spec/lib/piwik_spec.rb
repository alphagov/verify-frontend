require 'piwik'
require 'active_support/core_ext/string'

RSpec.describe Piwik do
  let(:config) { double(:config) }

  before(:each) do
    allow(config).to receive(:piwik_host)
    allow(config).to receive(:piwik_port)
    allow(config).to receive(:piwik_site_id)
  end

  it 'reads config to generate a url' do
    expect(config).to receive(:piwik_host).and_return('http://www.example.com').twice
    expect(config).to receive(:piwik_port).and_return(1234)

    piwik = Piwik.new(config)

    expect(piwik.url).to eql 'http://www.example.com:1234/piwik.php'
  end

  it 'has a site id' do
    expect(config).to receive(:piwik_site_id).and_return(5)

    piwik = Piwik.new(config)

    expect(piwik.site_id).to eql 5
  end

  it 'is disabled when piwik_host is nil' do
    expect(config).to receive(:piwik_host).and_return(nil).twice

    piwik = Piwik.new(config)

    expect(piwik.enabled?).to eql false
  end

  it 'is disabled when piwik_host is an empty string' do
    expect(config).to receive(:piwik_host).and_return('').twice

    piwik = Piwik.new(config)

    expect(piwik.enabled?).to eql false
  end

  it 'is enabled when piwik_host is present' do
    expect(config).to receive(:piwik_host).and_return('abc').twice

    piwik = Piwik.new(config)

    expect(piwik.enabled?).to eql true
  end
end
