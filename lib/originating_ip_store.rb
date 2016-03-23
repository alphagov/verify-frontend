require 'request_store'
module OriginatingIpStore
  UNDETERMINED_IP = '<PRINCIPAL IP ADDRESS COULD NOT BE DETERMINED>'

  def self.store(request)
    originating_ip = request.headers.fetch('X-Forwarded-For') { UNDETERMINED_IP }
    RequestStore.store[:originating_ip] = originating_ip
  end

  def self.get
    RequestStore.store[:originating_ip]
  end
end
