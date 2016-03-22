require 'http'

module Analytics
  class PiwikClient
    def initialize(piwik_url, ssl_context)
      @ssl_context = ssl_context
      @piwik_url = piwik_url
    end

    def report(params, headers = {})
      client(headers).get(@piwik_url, params: params, ssl_context: @ssl_context)
    rescue HTTP::Error => e
      Rails.logger.error('Analytics reporting error: ' + e.message)
    end

  private

    def client(headers)
      HTTP.headers(headers)
    end
  end
end
