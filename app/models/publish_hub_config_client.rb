require 'pooling_client'

class PublishHubConfigClient
  def initialize(host)
    user_agent = 'Verify Frontend Micro Service Client'
    @client = PoolingClient.new(host, 'User-Agent' => user_agent)
  end

  def healthcheck
    @client.get('/service-status')
  end

  def certificates(path)
    @client.get('/config/certificates/' + path)
  end
end
