require 'piwik'
require 'active_support/core_ext/string'

RSpec.describe Piwik do
  it 'reads config to generate a url' do
    config = double(:config)
    expect(config).to receive(:piwik_host).and_return('http://www.example.com').twice
    expect(config).to receive(:piwik_port).and_return(1234)

    piwik = Piwik.new(config)

    expect(piwik.url).to eql 'http://www.example.com:1234/piwik.php'
  end

  it 'is disabled when piwik_host is nil' do
    config = double(:config)
    expect(config).to receive(:piwik_host).and_return(nil).twice
    allow(config).to receive(:piwik_port)

    piwik = Piwik.new(config)

    expect(piwik.enabled?).to eql false
  end

  it 'is disabled when piwik_host is an empty string' do
    config = double(:config)
    expect(config).to receive(:piwik_host).and_return('').twice
    allow(config).to receive(:piwik_port)

    piwik = Piwik.new(config)

    expect(piwik.enabled?).to eql false
  end

  it 'is disabled when piwik_host is present' do
    config = double(:config)
    expect(config).to receive(:piwik_host).and_return('abc').twice
    allow(config).to receive(:piwik_port)

    piwik = Piwik.new(config)

    expect(piwik.enabled?).to eql true
  end
end
