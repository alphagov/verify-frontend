require 'pooling_client'

module Analytics
  class PiwikClient
    def initialize(piwik_url)
      @path = piwik_url.path
      @client = PoolingClient.new(piwik_url, {})
    end

    def report(params, headers = {})
      Thread.new do
        begin
          client.get(@path, params: params, headers: headers)
        rescue HTTP::Error => e
          Rails.logger.error('Analytics reporting error: ' + e.message)
        end
      end
    end

  private

    attr_reader :client
  end
end
