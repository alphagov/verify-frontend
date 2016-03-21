require 'http'

module Analytics
  class PiwikClient
    def initialize(ssl_context)
      @ssl_context = ssl_context
    end

    def report(params)
      client.get(PIWIK.url, params: params, ssl_context: @ssl_context)
    rescue HTTP::Error => e
      Rails.logger.error('Analytics reporting error: ' + e.message)
    end

  private

    def client
      HTTP.headers('User-Agent' => 'Verify Frontend Micro Service Client')
    end
  end
end
