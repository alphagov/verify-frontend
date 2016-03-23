require 'spec_helper'
require 'originating_ip_store'

describe OriginatingIpStore do
  it 'should store the originating ip from request headers' do
    request = double(:request)
    expect(request).to receive(:headers).and_return('X-Forwarded-For' => 'my thing')
    OriginatingIpStore.store(request)
    expect(OriginatingIpStore.get).to eql 'my thing'
  end

  it 'should store a default value if the header is not present' do
    request = double(:request)
    expect(request).to receive(:headers).and_return({})
    OriginatingIpStore.store(request)
    expect(OriginatingIpStore.get).to eql OriginatingIpStore::UNDETERMINED_IP
  end
end
