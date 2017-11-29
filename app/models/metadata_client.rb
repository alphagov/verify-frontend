require 'pooling_client'

class MetadataClient
  def initialize(host)
    user_agent = 'Verify Frontend Micro Service Client'
    @client = PoolingClient.new(host, 'User-Agent' => user_agent)
  end

  def sp_metadata
    response = @client.get('/API/metadata/sp')
    handle_response(response)
  end

  def idp_metadata
    response = @client.get('/API/metadata/idp')
    handle_response(response)
  end

  def handle_response(response)
    if response.status == 200
      json_output = MultiJson.load(response.to_s)
      json_output.fetch('saml') { raise 'Received 200, but could not find saml on response' }
    else
      raise Api::UpstreamError, "Expected 200 and got #{response.status}"
    end
  end
end
